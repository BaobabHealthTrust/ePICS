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
      @product_expire_details = {}
      epics_products = EpicsProduct.all
      epics_products.map{|product| @product_expire_details[product.name] = product.expire }
    end
  end

  def create
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

  def checkout
    stock = session[:stock]
    stock_details = find_product_cart

    unless stock.nil?
      unless stock_details.nil?
        EpicsStock.transaction do
          @stock = EpicsStock.new()
          @stock.grn_date = stock[:grn_date]
          @stock.grn_number = stock[:grn_number]
          @stock.epics_supplier_id = stock[:supplier_id]
          @stock.save!

          for item in stock_details.items
            @stock_detail = EpicsStockDetails.new()
            @stock_detail.epics_stock_id = @stock.epics_stock_id
            @stock_detail.epics_products_id = item.product_id
            @stock_detail.epics_location_id = item.location
            @stock_detail.quantity = item.quantity
            @stock_detail.epics_product_units_id = item.product.epics_product_units_id
            @stock_detail.save!

            unless item.expiry_date.blank?
              @stock_expiry_dates = EpicsStockExpiryDates.new()
              @stock_expiry_dates.epics_stock_details_id = @stock_detail.epics_stock_details_id
              @stock_expiry_dates.expiry_date = item.expiry_date
              @stock_expiry_dates.save!
            end
           end
           session[:cart] = session[:stock] = nil
        end
      end
    end
    
  end

  protected
  
  def find_product_cart
    session[:cart] ||= ProductCart.new
  end

end
