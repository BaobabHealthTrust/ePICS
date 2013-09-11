class ProductTypeController < ApplicationController
  def index
    @product_types = EpicsProductType.all
    render :layout => "custom"
  end

  def new
    @product_types = EpicsProductType.new
  end

  def create
    @product_type = EpicsProductType.new
    @product_type.name = params[:product_type][:name]
    @product_type.description = params[:product_type][:description]
    if @product_type.save!
       redirect_to :action => :index
    else
       redirect_to :action => :new
    end

  end

  def edit
    @product_type = EpicsProductType.find(params[:product_type])
  end

  def update
    @product_type = EpicsProductType.find(params[:product_type][:product_type_id])
    @product_type.name = params[:product_type][:name]
    @product_type.description = params[:product_type][:description]

    if @product_type.save!
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :product_type_id => params[:product_type][:product_type_id]
    end
  end

  def void
    @product_type = EpicsProductType.find(params[:product_type_id])
    @product_type.voided = 1
    @product_type.save!
		render :text => 'showMsg("Record Deleted!")'
  end

end
