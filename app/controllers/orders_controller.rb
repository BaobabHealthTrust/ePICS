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
    raise params.to_yaml
  end
   
 protected                                                                     
                                                                                
 def find_product_cart                                                         
   session[:orders] ||= ProductCart.new 
 end

end
