class ProductCategoryController < ApplicationController

  def index
    @product_categories = EpicsProductCategory.all
    render :layout => false
  end

  def new
    @product_category = EpicsProductCategory.new()
  end

  def create
    @product_category = EpicsProductCategory.new
    raise params @product_category.to_yaml
    @product_category.name = params[:product_category][:name]
    @product_category.description = params[:product_category][:description]
    if @product_category.save
       redirect_to :action => :index
    else
       redirect_to :action => :new
    end
  end

  def edit
    @product_category = EpicsProductCategory.find(params[:product_category])
  end

  def update
    @product_category = EpicsProductCategory.find(params[:product_category][:product_category_id])
    @product_category.name = params[:product_category][:name]
    @product_category.description = params[:product_category][:description]

    if @product_category.save
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :product_category_id => params[:product_category][:product_category_id]
    end
  end

  def void
    @product_category = EpicsProductCategory.find(params[:product_category_id])
    @product_category.voided = 1
    @product_category.save!
		render :text => 'showMsg("Record Deleted!")'
  end
  
end
