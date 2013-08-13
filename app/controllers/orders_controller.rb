class OrdersController < ApplicationController

  def index
    @location = EpicsLocation.where("name = ?", params[:location])[0]
    @cart = find_product_cart('issue')
    render :layout => 'custom'
  end

  def new
    @order = EpicsOrderTypes.all.map{|order| [order.name,order.epics_order_type_id]}
  end

  def create
    @cart = find_product_cart('issue')
    product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
    quantity = params[:item]['quantity'].to_f
    expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
    @cart.add_product(product,quantity,nil,expiry_date)
    redirect_to :action => :index, :location => EpicsLocation.find(session[:issuing_location_id]).name
  end

  def edit
  end

  def update
  end

  def void
  end

  def select
    @product_category_map = EpicsProductCategory.all.map do |product_category|
      [product_category.name,product_category.epics_product_category_id]
    end

    if session[:issuing_location_id].blank?
      @location = EpicsLocation.find_by_name(params['location'])
      session[:issuing_location_id] = @location.id
    end 
    @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }
  end
 
  def dispense
    items = {}

    (params[:item_quantity] || {}).each do |name , quantity|
      name = ActiveSupport::JSON.decode name
      items[name] = {:quantity => 0 , :expiry_date => nil} if items[name].blank?
      items[name][:quantity] = quantity
    end

    (params[:item_expiry_date] || {}).each do |name , expiry_date|
      name = ActiveSupport::JSON.decode name
      items[name][:expiry_date] = expiry_date
    end

    ord_type = ActiveSupport::JSON.decode params[:type]
    order_type = EpicsOrderTypes.find_by_name(ord_type)
    EpicsOrders.transaction do
      order = EpicsOrders.new() 
      order.epics_order_type_id = order_type.id rescue 1
      order.save

      (items || {}).each do |name , values|
        get_stock_detail(name , values).each do |stock_id , quantity|
          item_order = EpicsProductOrders.new()
          item_order.epics_order_id = order.id
          item_order.epics_stock_details_id = stock_id
          item_order.quantity = quantity
          item_order.save


          if ord_type.eql?('lend')

            fname = session[:lend_details]['authorizer'].split(" ")[0].squish!
            lname = session[:lend_details]['authorizer'].split(" ")[1].squish!
            person = EpicsPerson.where("fname = ? AND lname = ?",fname,lname ).first.id

            lend = EpicsLendsOrBorrows.new
            lend.epics_orders_id = order.id
            lend.facility = session[:lend_details]['lend_to_location'].id
            lend.lend_or_borrow_date = session[:lend_details]['issue_date']
            lend.epics_lends_or_borrows_type_id = EpicsLendsOrBorrowsType.find_by_name("lend").id
            lend.return_date = session[:lend_details]['return_date']
            lend.save

            authorizer = EpicsLendBorrowAuthorizer.new
            authorizer.epics_person_id = person
            authorizer.epics_lends_or_borrows_id = lend.id
            authorizer.save

          end
          update_stock_details(stock_id, quantity)
        end
      end
    end

    if ord_type == 'lend'
      session[:lent_items] = nil
      session[:lend_details] = nil
    else
      session[:orders] = nil
    end

    redirect_to "/"
  end

  def get_authoriser

    render :text => EpicsPerson.get_authorisers(params[:search_string])
  end

 def lend


 end

 def lend_index
   @cart = find_product_cart('lend')
   if session[:lend_details].blank?
     @location = EpicsLocation.find_by_name(params[:facility])

     session[:lend_details] = {}
     session[:lend_details]['lend_to_location'] = @location
     session[:lend_details]['issue_date'] = params[:issue_date]
     session[:lend_details]['return_date'] = params[:return_date]
     session[:lend_details]['authorizer'] = params[:authorizer]
   end
   render :layout => 'custom'
 end

 def lend_create

   @product_category_map = EpicsProductCategory.all.map do |product_category|
     [product_category.name,product_category.epics_product_category_id]
   end

   @product_expire_details = {}
   epics_products = EpicsProduct.all
   epics_products.map{|product| @product_expire_details[product.name] = product.expire }

   if request.post?
     @cart = find_product_cart('lend')
     product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
     quantity = params[:item]['quantity'].to_f
     expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
     @cart.add_product(product,quantity,nil,expiry_date)
    redirect_to :action => :lend_index, :location => session[:lend_details]['lend_to_location'].id
   end

 end

 def remove_product_from_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:orders]
    cart.remove_product(product)
    render :text => "true"

  end


  def return_loans

    facilities = EpicsLendsOrBorrows.find(:all,
                                        :conditions => ["epics_lends_or_borrows_type_id = ? AND reimbursed = false",
                                                        EpicsLendsOrBorrowsType.find_by_name('borrow').id]).collect{|x| x.facility}

    @debtors = EpicsLocation.find(:all, :conditions => ["epics_location_id IN (?)", facilities]).collect{|x| x.name}.uniq

  end

 def remove_product_from_lend_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:lent_items]
    cart.remove_product(product)
    render :text => "true"
 end
 

 protected                                                                     
                                                                                
 def find_product_cart(type)
   case (type)
     when 'lend'
      session[:lent_items] ||= ProductCart.new
     when 'issue'
      session[:orders] ||= ProductCart.new
   end

 end

  def get_stock_detail(name, values)
    details = EpicsStockDetails.joins("INNER JOIN epics_products e 
      ON e.epics_products_id = epics_stock_details.epics_products_id").where("e.name" => name)

    max_quantity = values[:quantity].to_f
    stock_details = []

    (details || []).each do |e|
      next if e.current_quantity < 1
      break if max_quantity == 0
      if e.current_quantity <= max_quantity
        stock_details << [e.id, e.current_quantity]
        max_quantity -= e.current_quantity
      else
        stock_details << [e.id, max_quantity]
        max_quantity = 0
        break
      end
    end

    return stock_details
  end

 def update_stock_details(stock_id, quantity)

  old_stock = EpicsStockDetails.find(stock_id)

  old_stock.current_quantity = (old_stock.current_quantity - quantity)
  old_stock.save
 end

end
