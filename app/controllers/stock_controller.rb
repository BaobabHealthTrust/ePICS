class StockController < ApplicationController
  def index
  end

  def new
    @supplier_map = EpicsSupplier.all.map{|supplier| [supplier.name, supplier.epics_supplier_id]}
    @people = EpicsPerson.all.map{|person| [[person.fname+" "+ person.lname]]}

  end

  def create
    
    session[:stock] = nil
    stock_hash = Hash.new()
    stock_hash[:supplier_id] = params[:stock][:supplier_id]
    stock_hash[:grn_number] = params[:stock][:grn_number]
    stock_hash[:grn_date] = params[:stock][:grn_date]
    stock_hash[:witness_names] = params[:stock][:witness_names]
    session[:stock] = stock_hash

    unless session[:stock].nil?
      redirect_to :controller => :stock_details, :action => :new
    else
      redirect_to :action => :new
    end
  end

  def edit
  end

  def update
  end

  def void
  end

  def borrow
    @supplier_map =  EpicsLocationType.find(:first, :conditions => ["name = 'Facility'"]).epics_locations.collect{|x| x.name }
    @authorizers = OpenmrsPerson.get_authorisers

  end

  def borrow_index

    @borrow_cart =  (session[:borrow_cart] ||= ProductCart.new)

    if request.post?
      session[:borrow] = nil
      borrow_hash = Hash.new()
      borrow_hash[:borrowing_from] = params[:facility]
      borrow_hash[:supplier_id] = EpicsSupplier.find_by_name("Other").id
      borrow_hash[:grn_number] = params[:grn_number]
      borrow_hash[:authorizer] = params[:authorizer]
      borrow_hash[:grn_date] = params[:borrow_date]
      borrow_hash[:return_date] = params[:return_date]
      borrow_hash[:witness_names] = params[:witness_name]
      session[:borrow] = borrow_hash

    end

    render :layout => "custom"

  end

  def receive_loan_returns
    facilities = EpicsLendsOrBorrows.find(:all,
                                          :conditions => ["epics_lends_or_borrows_type_id = ? AND reimbursed = false",
                                                          EpicsLendsOrBorrowsType.find_by_name('Lend').id]).collect{|x| x.facility}

    @creditors = EpicsLocation.find(:all, :conditions => ["epics_location_id IN (?)", facilities]).collect{|x| x.name}.uniq

  end

  def get_returners_details

    session[:item_returns] = {}
    session[:item_returns][:lent_to] = params[:facility]
    session[:item_returns][:grn_number] = params[:grn_number]
    session[:item_returns][:grn_date] = params[:grn_date]
    session[:item_returns][:witness_names] = params[:witness_names]
    session[:item_returns][:supplier_id] = EpicsSupplier.find_by_name('Other').id

    @dates = EpicsLendsOrBorrows.find(:all, 
      :conditions=> ["reimbursed = false AND facility = ? AND epics_lends_or_borrows_type_id = ?",
      EpicsLocation.find_by_name(params[:facility]).id,
      EpicsLendsOrBorrowsType.find_by_name("Lend").id]).map{|x| [x.lend_or_borrow_date, x.epics_orders_id]}

    #render :layout => "application"
    render :layout => "report"
  end

  def get_lent_items

    details = {}

    temp = EpicsProductOrders.find_all_by_epics_order_id(params[:id])

    temp.each do |f|
      details[f.epics_stock_details.epics_product.name] =  f.quantity
    end

#    raise details.inspect

    render :json => details
  end

  def reimburse_index

  end

  def get_witness_names
    @names = EpicsWitnessNames.where("name LIKE (?)",
                                     "%#{params[:search_string]}%").map{|witness|[[witness.name]]}

    render :text => "<li></li><li>" + @names.uniq.join("</li><li>") + "</li>"
  end

 def remove_product_from_borrow_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:borrow_cart]
    cart.remove_product(product)
    render :text => "true"
 end

  def get_batches_not_reimbursed_to_facility

    loans = EpicsLendsOrBorrows.find(:all,
                                     :conditions => ["epics_lends_or_borrows_type_id = ? AND reimbursed = false AND facility = ? ",
                                      EpicsLendsOrBorrowsType.find_by_name(params[:type]).id,
                                      EpicsLocation.find_by_name(params[:facility]).id])

    batches = EpicsStock.find(:all, :conditions => ["epics_stock_id IN (?)", loans.collect{|c| c.epics_stock_id}]).collect{|x| x.grn_number}

    render :text => "<li></li><li>" + batches.join("</li><li>") + "</li>"
  end

  def get_items_by_batch_number
    items = EpicsStock.joins("INNER JOIN epics_stock_details s 
      ON s.epics_stock_id = epics_stocks.epics_stock_id 
      AND epics_stocks.grn_number = '#{params[:number]}' INNER JOIN epics_products p 
      ON p.epics_products_id = s.epics_products_id").select("p.product_code, 
      p.name, s.received_quantity").map do |r|
        {:code => r.product_code,:item_name => r.name,:quantity => r.received_quantity}
      end
    
    @html = "<div id='borrowed_items_one'><div id='borrowed_items_two'>"
    @html += "<table class='borrowed_items' style='width: 98%;'>"
    @html += "<tr><th>Item code</th><th>Item</th><th style='text-align: right; padding-right: 10px;'>Quantity</th></tr>"
    @html += "<tr><td colspan='3'><hr /></td></tr>"

    (items || []).each do |i|
      @html+=<<EOF
      <tr>
        <td>#{i[:code]}</td>
        <td>#{i[:item_name]}</td>
        <td style='text-align: right; padding-right: 10px';>#{i[:quantity]}</td>
      </tr>
      <tr>
        <td colspan='3'><hr /></td>
      </tr>
EOF

    end 
      @html += "</table>"
      @html += "</div><table style='width:100%;'>"
      @html += "<tr><td><a class='buttons' href='javascript:hideLayer();'>Close</a></td></tr>"
      @html += "</table></div>"
    
    render :text => @html and return
  end

  def confirmations
    @reminders = {}
    pending = EpicsLendBorrowAuthorizer.find(:all, :conditions => ["voided = ? AND authorized = ?",false,false])

    (pending || {}).each do |x|

      item = {
          "trans_type" => x.epics_lends_or_borrows.epics_lends_or_borrows_type.name,
          "facility" => EpicsLocation.find(x.epics_lends_or_borrows.facility).name,
          "authorizer" => OpenmrsPersonName.find(:last, :conditions =>["person_id = ?", User.find(x.authorizer).person_id]).full_name,
          "authorizer_id" => x.authorizer
      }

      @reminders[x.id] = item
    end

    @can_authorize = User.current.epics_user_role.name == "Administrator" ? "block" : "none"

    #raise @reminders.inspect
  end

  def authorize_transaction
    transaction = EpicsLendBorrowAuthorizer.find(params[:id])
    transaction.authorized = true
    if transaction.save
      render :json => true
    else
      render :json => false
    end
  end

   def get_items_by_order_id 
    product_orders = EpicsProductOrders.find_all_by_epics_order_id(params[:order_id])
                                                                                
    @html = "<div id='borrowed_items_one'><div id='borrowed_items_two'>"        
    @html += "<table class='borrowed_items' style='width: 98%;'>"               
    @html += "<tr><th>Item code</th><th>Item</th><th style='text-align: right; padding-right: 10px;'>Quantity</th></tr>"
    @html += "<tr><td colspan='3'><hr /></td></tr>"                             
                                                                                
    (product_orders || []).each do |product_order|
      code = product_order.epics_stock_details.epics_product.product_code
      name = product_order.epics_stock_details.epics_product.name
      quantity = product_order.quantity            
      @html+=<<EOF                                                              
      <tr>                                                                      
        <td>#{code}</td>                                                    
        <td>#{name}</td>                                               
        <td style='text-align: right; padding-right: 10px';>#{quantity}</td>
      </tr>                                                                     
      <tr>                                                                      
        <td colspan='3'><hr /></td>                                             
      </tr>                                                                     
EOF
                                                                                
                                                                                
    end                                                                         
      @html += "</table>"                                                       
      @html += "</div><table style='width:100%;'>"                              
      @html += "<tr><td><a class='buttons popbtn' href='javascript:hideLayer();'>Close</a></td>"
      @html += "<td><a class='buttons popbtn' href='javascript:selectOrder(#{params[:order_id]});'>Select</a></td></tr>"
      @html += "</table></div>"                                                 
                                                                                
    render :text => @html and return                                            
  end

end
