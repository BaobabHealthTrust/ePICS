class StockDetailsController < ApplicationController
  def index
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
    raise session[:stock].inspect
    raise params.to_yaml
  end

  def edit
  end

  def update
  end

  def void
  end

end
