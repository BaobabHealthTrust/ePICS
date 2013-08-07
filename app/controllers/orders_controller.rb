class OrdersController < ApplicationController

  def index
    @location = EpicsLocation.where("name = ?", params[:location])[0]
    @cart = [] #find_product_cart
  end

  def new
    @order = EpicsOrderTypes.all.map{|order| [order.name,order.epics_order_type_id]}
  end

  def create
    @cart = find_product_cart
    product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
    quantity = params[:item]['quantity'].to_f
    location = EpicsLocation.find(params[:item]['location_id']) rescue 1
    expiry_date = product.expiry_date rescue nil
    @cart.add_product(product,quantity,location.id,expiry_date)
    redirect_to :action => :index
  end

  def edit
  end

  def update
  end

  def void
  end

  def cart
    @cart = find_product_cart                                                   
    product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
    quantity = params[:item]['quantity'].to_f                           
    location = EpicsLocation.find(params[:item]['location_id'])
    expiry_date = product.expiry_date rescue nil                
    @cart.add_product(product,quantity,location.id,expiry_date) 

    redirect_to :action => 'index', :location => location.name 
  end

  def select
    @product_category_map = EpicsProductCategory.all.map do |product_category|
        [product_category.name,product_category.epics_product_category_id]
      end
    @location = EpicsLocation.find_by_name(params['location']) 
  end
  
 protected                                                                     
                                                                                
 def find_product_cart                                                         
   session[:orders] ||= ProductCart.new 
 end

end
