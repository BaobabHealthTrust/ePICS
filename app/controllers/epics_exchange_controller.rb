class EpicsExchangeController < ApplicationController

  def create

    session[:exchange] = nil
    exchange_hash = Hash.new()
    exchange_hash[:exchange_facility] = params[:location]
    exchange_hash[:exchange_date] = params[:exchange_date]
    session[:exchange] = exchange_hash

    unless session[:exchange].nil?
      redirect_to :controller => :epics_exchange, :action => :new
    else
      redirect_to :action => :new
    end


  end

  def new
    @issue_cart = find_product_issue_cart
    @receive_cart = find_product_receive_cart
    
    render :layout => 'custom'
  end

  def index

  end

  def give_item
     @product_category_map = EpicsProductCategory.all.map do |product_category|
      [product_category.name,product_category.epics_product_category_id]
    end
     @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }
    
    if request.post?
      @location = EpicsLocation.find_by_name(params['location'])
      @issue_cart = find_product_issue_cart
      product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
      quantity = params[:item]['quantity'].to_f
      expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
      @issue_cart.add_product(product,quantity,nil,expiry_date)
      @receive_cart = find_product_receive_cart
     # session[:issuing_location_id] = @location.id
      redirect_to :action => "new"
    end
  end

  def add_items_to_cart(items)
    
  end

  def find_product_issue_cart
   session[:issue] ||= ProductCart.new
  end

  def find_product_receive_cart
   session[:receive] ||= ProductCart.new
  end

end
