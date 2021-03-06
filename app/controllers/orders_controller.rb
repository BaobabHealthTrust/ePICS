class OrdersController < ApplicationController

  def index
    @location = EpicsLocation.where("name = ?", params[:location])[0]
    @cart = find_product_cart('issue')
    @page_title = "Issuing Items"
    render :layout => 'custom'
  end

  def new
    locations = EpicsLocationType.where("name in ('Departments', 'store room')").collect{|x| x.id}
    @order = EpicsOrderTypes.all.map{|order| [order.name,order.epics_order_type_id]}
    @locations_map = EpicsLocation.where("epics_location_type_id in (?) ", locations
      ).map do |location|
        [location.name, location.epics_location_id] unless location.epics_location_id == session[:location_id]
      end
  end

  def create
    @cart = find_product_cart('issue')
    product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
    quantity = ((params[:item]['issue_quan'].blank? ? params[:item]['issue_quantity'] : params[:item]['issue_quan'] ).to_i * params[:item]['item_quantity'].to_i) rescue 1
    expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
    @cart.add_product(product,nil,quantity,nil,expiry_date)
    redirect_to :action => :index, :location => EpicsLocation.find(session[:issuing_location_id]).name
  end

  def edit
  end

  def update
  end

  def void
  end

  def select

    if session[:issue_date].blank?
      session[:issue_date] = params[:issue_date].to_date
    end

    @product_category_map = EpicsProductCategory.all.map do |product_category|
      [product_category.name,product_category.epics_product_category_id]
    end

    if session[:issuing_location_id].blank?
      @location = EpicsLocation.find(params['location'])
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
      created_at = "#{session[:lend_details]['issue_date'].to_date} #{Time.now.strftime('%H:%M:%S')}" rescue nil
      if created_at.blank?
        created_at = "#{session[:return_details][:date].to_date} #{Time.now.strftime('%H:%M:%S')}" rescue nil
      end

      epics_location_id = params[:issue_to]
      if epics_location_id.blank?
        epics_location_id = EpicsLocation.find_by_name(session[:return_details][:return_to]).id rescue nil
      end

      raise "Issuing Location site not set ...." if epics_location_id.blank?

      order = EpicsOrders.new() 
      order.epics_order_type_id = order_type.id 
      order.epics_location_id = epics_location_id
      order.created_at = created_at
      order.save

      (items || {}).each do |name , values|
        get_stock_detail(name , values).each do |stock_id , quantity|
          item_order = EpicsProductOrders.new()
          item_order.epics_order_id = order.id
          item_order.epics_stock_details_id = stock_id
          item_order.quantity = quantity
          item_order.created_at = "#{order.created_at.to_date} #{Time.now.strftime('%H:%M:%S')}"
          item_order.save


          if ord_type.eql?('lend')

            lend = EpicsLendsOrBorrows.new
            lend.epics_orders_id = order.id
            lend.facility = session[:lend_details]['lend_to_location'].id
            lend.lend_or_borrow_date = session[:lend_details]['issue_date']
            lend.epics_lends_or_borrows_type_id = EpicsLendsOrBorrowsType.find_by_name("lend").id
            lend.return_date = session[:lend_details]['return_date']
            lend.save

            authorizer = EpicsLendBorrowAuthorizer.new
            authorizer.authorizer = session[:lend_details]['authorizer']
            authorizer.epics_lends_or_borrows_id = lend.id
            authorizer.save

          elsif ord_type.eql?('donate')
            donate = EpicsLendsOrBorrows.new
            donate.epics_orders_id = order.id
            donate.facility = session[:donation_details]['donate_to_location'].id
            donate.lend_or_borrow_date = session[:donation_details]['issue_date']
            donate.return_date = session[:donation_details]['issue_date']
            donate.epics_lends_or_borrows_type_id = EpicsLendsOrBorrowsType.find_by_name("donate").id
            donate.save

            authorizer = EpicsLendBorrowAuthorizer.new
            authorizer.authorizer = session[:donation_details]['authorizer']
            authorizer.epics_lends_or_borrows_id = donate.id
            authorizer.save

          elsif ord_type.eql?('return')
            lend = EpicsLendsOrBorrows.find(:first, 
              :conditions => ["epics_stock_id = ?",
              EpicsStock.find_by_invoice_number(session[:return_details][:return_batch]).id ])
            lend.epics_orders_id = order.id
            lend.reimbursed = true
            lend.save

          end
          update_stock_details(stock_id, quantity)
        end
      end
    end

    if ord_type == 'lend'
      session[:lent_items] = nil
      session[:lend_details] = nil

    elsif ord_type == 'return'
      session[:return_details] = nil
      session[:reimburse_cart] = nil

    elsif ord_type == 'donate'
      session[:donation_details] = nil
      session[:donate_cart] = nil
    else
      session[:orders] = nil
    end

    redirect_to "/"
  end

  def get_authoriser

    render :text => OpenmrsPerson.get_authorisers
  end

 def lend

   @locations = EpicsLocationType.find(:first, :conditions => ["name = 'Facility'"]).epics_locations.collect{|x| x.name }
   @authorizers = OpenmrsPerson.get_authorisers

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
     name = OpenmrsPersonName.find(:last, :conditions =>["person_id = ?", User.find(params[:authorizer]).person_id])
     session[:lend_details]['authorizer_name'] = name.full_name
   end
   @page_title = "Lending Out Items"
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
     quantity = ((params[:item]['issue_quan'].blank? ? params[:item]['issue_quantity'] : params[:item]['issue_quan'] ).to_i * params[:item]['item_quantity'].to_i) rescue 1
     expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
     @cart.add_product(product,nil,quantity,nil,expiry_date)
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

  def remove_reimburse_from_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:reimburse_cart]
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

  def remove_product_from_donate_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:donate_cart]
    cart.remove_product(product)
    render :text => "true"
  end

  def reimburse_index
    @return_cart = session[:reimburse_cart] ||= ProductCart.new

    if request.post?
      session[:return_details] = {}
      session[:return_details][:return_to] = params["facility"]
      session[:return_details][:return_batch] = params["batch"]
      session[:return_details][:date] = params["reimburse_date"].to_date
    end
    @page_title = "Returning Borrowed Items"
    render :layout => "custom"
  end

  def select_item_to_return


    if request.post?

      @return_cart = session[:reimburse_cart] ||= ProductCart.new
      product = EpicsProduct.find_by_name(params[:item][:name])
      quantity = ((params[:item]['issue_quan'].blank? ? params[:item]['issue_quantity'] : params[:item]['issue_quan'] ).to_i * params[:item]['item_quantity'].to_i) rescue 1
      expiry_date = params[:item][:expiry_date]
      @return_cart.add_product(product,nil,quantity,location,expiry_date)

      redirect_to :action => :reimburse_index

    end

    @locations_map = EpicsLocation.find(:all, :conditions => ["epics_location_type_id = ? ",
                                                              EpicsLocationType.find_by_name("Store room").id ]).map{|location| [location.name,location.epics_location_id]}
    @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}
    @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }

  end

  def donate
    @locations = EpicsLocationType.find(:first, :conditions => ["name = 'Facility'"]).epics_locations.collect{|x| x.name }
    @authorizers = OpenmrsPerson.get_authorisers
  end

  def donate_index
    @cart = session[:donate_cart] ||= ProductCart.new

    if request.post?
      product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
      quantity = ((params[:item]['issue_quan'].blank? ? params[:item]['issue_quantity'] : params[:item]['issue_quan'] ).to_i * params[:item]['item_quantity'].to_i) rescue 1
      expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
      @cart.add_product(product,nil,quantity,nil,expiry_date)
    end

    @page_title = "Donating Items"
    render :layout => 'custom'
  end

  def select_donation_item
    if request.post?
      @location = EpicsLocation.find_by_name(params[:facility])
      name = OpenmrsPersonName.find(:last, :conditions =>["person_id = ?", User.find(params[:authorizer]).person_id])

      session[:donation_details] = {}
      session[:donation_details]['donate_to_location'] = @location
      session[:donation_details]['issue_date'] = params[:issue_date]
      session[:donation_details]['authorizer'] = params[:authorizer]
      session[:donation_details]['authorizer_name'] = name.full_name
    end

    @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}
    @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }

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
      ON e.epics_products_id = epics_stock_details.epics_products_id
      INNER JOIN epics_stock_expiry_dates x 
      ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id 
      ").where("e.name = ? AND x.expiry_date = ?",name,values[:expiry_date])

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

  if max_quantity > 0
    details = EpicsStockDetails.joins("INNER JOIN epics_products e 
      ON e.epics_products_id = epics_stock_details.epics_products_id
      INNER JOIN epics_stock_expiry_dates x 
      ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id 
      ").where("e.name = ? AND x.expiry_date <> ?",name,values[:expiry_date])
    
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

   end
    
    return stock_details
  end

 def update_stock_details(stock_id, quantity)
  old_stock = EpicsStockDetails.find(stock_id)
  old_stock.current_quantity = (old_stock.current_quantity - quantity)
  old_stock.save
 end

end
