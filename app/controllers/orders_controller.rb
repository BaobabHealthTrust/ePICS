class OrdersController < ApplicationController

  def index
    @location = EpicsLocation.where("name = ?", params[:location])[0]
    @cart = find_product_cart
    render :layout => 'custom'
  end

  def new
    @order = EpicsOrderTypes.all.map{|order| [order.name,order.epics_order_type_id]}
  end

  def create
    @cart = find_product_cart
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

    order_type = EpicsOrderTypes.find_by_name('Dispense')

    (items || {}).each do |name , values|
      EpicsOrders.transaction do
        order = EpicsOrders.new()
        order.epics_order_type_id = order_type.id
        if order.save
          get_stock_detail(name , values).each do |stock_id , quantity|
            item_order = EpicsProductOrders.new()
            item_order.epics_order_id = order.id
            item_order.epics_stock_details_id = stock_id
            item_order.quantity = quantity
            item_order.save
          end
        end
      end
    end

    session[:orders] = nil
    redirect_to "/"
  end
   
 protected                                                                     
                                                                                
 def find_product_cart                                                         
   session[:orders] ||= ProductCart.new 
 end

  def get_stock_detail(name, values)
    details = EpicsStockDetails.joins("INNER JOIN epics_products e 
      ON e.epics_products_id = epics_stock_details.epics_products_id").where("e.name" => name)

    max_quantity = values[:quantity].to_f
    stock_details = []

    (details || []).each do |e|
      next if e.quantity < 1
      stock_details << [e.id, e.quantity]
      if e.quantity >= max_quantity
        return [e.id , max_quantity]
      end
      dispensed_quantity = 0
      stock_details.map{|i , q| dispensed_quantity+=q}
      break if dispensed_quantity >= max_quantity
    end

    return stock_details
  end



end
