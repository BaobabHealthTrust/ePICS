class ProductController < ApplicationController
  def index
    @products = EpicsProduct.all
    render :layout => false
  end

  def new
    @product = EpicsProduct.new
    @product_type_map = EpicsProductType.all.map{|product_type|[product_type.name,product_type.epics_product_type_id]}
    @product_unit_map = EpicsProductUnits.all.map{|product_unit|[product_unit.name,product_unit.epics_product_units_id]}
  end

  def create
    
    @product = EpicsProduct.new
    @product.name = params[:name]
    @product.product_code = params[:product_code]
    @product.epics_product_units_id = params[:epics_product_units_id]
    @product.epics_product_type_id = params[:epics_product_type_id]
    @product.expire = params[:expire]
    @product.min_stock = params[:min_stock]
    @product.max_stock = params[:max_stock]

    if @product.save
      redirect_to :action => :index
    else
      redirect_to :action => :new
    end
  end

  def edit
    @product = EpicsProduct.find(params[:product])
    @product_type_map = EpicsProductType.all.map{|product_type|[product_type.name,product_type.epics_product_type_id]}
    @product_unit_map = EpicsProductUnits.all.map{|product_unit|[product_unit.name,product_unit.epics_product_units_id]}
  end

  def update
    @product = EpicsProduct.find(params[:product_id])
    @product.name = params[:name]
    @product.product_code = params[:product_code]
    @product.epics_product_units_id = params[:epics_product_units_id]
    @product.epics_product_type_id = params[:epics_product_type_id]
    @product.expire = params[:expire]
    @product.min_stock = params[:min_stock]
    @product.max_stock = params[:max_stock]

    if @product.save
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :product_id => params[:product_id]
    end
  end

  def void
    @product = EpicsProduct.find(params[:product_id])
    @product.voided = 1
    @product.save!
		render :text => 'showMsg("Record Deleted!")'
  end

end
