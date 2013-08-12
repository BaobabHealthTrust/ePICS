class ProductController < ApplicationController
  def index
    @products = EpicsProduct.all
    render :layout => "custom"
  end

  def view
    @product = EpicsProduct.where("name = ?",params[:product])[0]
    render :layout => "custom"
  end

  def search
  end

  def find_by_name_or_code
    @products = EpicsProduct.where("(product_code LIKE(?) OR
      name LIKE (?))", "%#{params[:search_str]}%",
      "%#{params[:search_str]}%").limit(100).map{|product|[[product.name]]}

    render :text => "<li></li><li>" + @products.join("</li><li>") + "</li>"
  end

  def new
    @product = EpicsProduct.new
    @product_type_map = EpicsProductType.all.map{|product_type|[product_type.name,product_type.epics_product_type_id]}
    @product_unit_map = EpicsProductUnits.all.map{|product_unit|[product_unit.name,product_unit.epics_product_units_id]}
    @product_category_map = EpicsProductCategory.all.map{|product_category|[product_category.name,product_category.epics_product_category_id]}
  end

  def create
    @product = EpicsProduct.new
    @product.name = params[:product][:name]
    @product.product_code = params[:product][:product_code]
    @product.epics_product_units_id = params[:product][:product_unit_id]
    @product.epics_product_type_id = params[:product][:product_type_id]
    @product.epics_product_category_id = params[:product][:product_category_id]
    @product.expire = params[:product][:expire]
    @product.min_stock = params[:product][:min_stock]
    @product.max_stock = params[:product][:max_stock]
    @product.movement = params[:product][:movement]

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
    @product_category_map = EpicsProductCategory.all.map{|product_category|[product_category.name,product_category.epics_product_category_id]}
  end

  def update
    @product = EpicsProduct.find(params[:product][:product_id])
    @product.name = params[:product][:name]
    @product.product_code = params[:product][:product_code]
    @product.epics_product_units_id = params[:product][:product_unit_id]
    @product.epics_product_type_id = params[:product][:product_type_id]
    @product.epics_product_category_id = params[:product][:product_category_id]
    @product.expire = params[:product][:expire]
    @product.min_stock = params[:product][:min_stock]
    @product.max_stock = params[:product][:max_stock]
    @product.movement = params[:product][:movement]

    if @product.save
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :product_id => params[:product][:product_id]
    end
  end

  def void
    @product = EpicsProduct.find(params[:product_id])
    @product.voided = 1
    @product.save!
		render :text => 'showMsg("Record Deleted!")'
  end

  def get_products
    #@products = EpicsProduct.where(:epics_product_category_id => params[:product_category_id]).map{|product|[[product.name]]}
    @products = EpicsProduct.where("epics_product_category_id = ? AND
      name LIKE (?)", params[:product_category_id],
      "%#{params[:search_str]}%").map{|product|[[product.name]]}

    render :text => "<li></li><li>" + @products.join("</li><li>") + "</li>"
  end

  def expire
    @expires = EpicsProduct.where(:name => params[:product_name]).first.expire
    render :text => @expires.to_s
  end

  def get_batch_details
    item = EpicsProduct.where("name=?",params[:name])[0]
    @products = []
    (item.epics_stock_details ||[]).each do |detail|
      next if detail.epics_stock_expiry_date.blank?
      @products << detail.epics_stock_expiry_date.expiry_date.to_date
    end
    render :text => "<li></li><li>" + @products.uniq.join("</li><li>") + "</li>"
  end

  def edit_product
    @product = EpicsProduct.find(params[:product_id])
    @product_type_map = EpicsProductType.all.map{|product_type|[product_type.name,product_type.epics_product_type_id]}
    @product_unit_map = EpicsProductUnits.all.map{|product_unit|[product_unit.name,product_unit.epics_product_units_id]}
    @product_category_map = EpicsProductCategory.all.map{|product_category|[product_category.name,product_category.epics_product_category_id]}
  end

  def save_edited_product
    @product = EpicsProduct.find(params[:product][:product_id])
    @product.name = params[:product][:name]
    @product.product_code = params[:product][:product_code]
    @product.epics_product_units_id = params[:product][:product_unit_id]
    @product.epics_product_type_id = params[:product][:product_type_id]
    @product.epics_product_category_id = params[:product][:product_category_id]
    @product.expire = params[:product][:expire]
    @product.min_stock = params[:product][:min_stock]
    @product.max_stock = params[:product][:max_stock]
    @product.movement = params[:product][:movement]
    if @product.save
       redirect_to :action => :view, :product =>params[:product][:name]
    else
       redirect_to :action => :edit, :product_id => params[:product][:product_id]
    end
  end
end
