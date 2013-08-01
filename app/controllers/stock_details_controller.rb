class StockDetailsController < ApplicationController


  def index
    @cart = find_product_cart
    render :layout => "custom"
  end

  def new
    unless session[:stock].nil?
      @stock_detail = EpicsStockDetails.new()
      @locations_map = EpicsLocation.all.map{|location| [location.name,location.epics_location_id]}
      @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}
      @product_map = EpicsProduct.all.map{|product| [product.name, product.epics_products_id]}
    end
  end

  def create
    #session[:cart] = nil
    @cart = find_product_cart
    product = EpicsProduct.find_by_name(params[:stock_details][:product_name])
    quantity = params[:stock_details][:quantity].to_f
    location = params[:stock_details][:location_id]
    expiry_date = params[:stock_details][:expiry_date]
    @cart.add_product(product,quantity,location,expiry_date)

    redirect_to :action => :index
  end

  def edit
  end

  def update
  end

  def void
  end

  protected
  
  def find_product_cart
    session[:cart] ||= ProductCart.new
  end

end
