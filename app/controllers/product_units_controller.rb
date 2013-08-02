class ProductUnitsController < ApplicationController
  
  def index
    @product_units = EpicsProductUnits.order(:name)
    render :layout => "custom"
  end

  def new
    @product_units = EpicsProductUnits.new()
  end

  def create
    @product_unit = EpicsProductUnits.new()
    @product_unit.name = params[:product_unit][:name]
    @product_unit.description = params[:product_unit][:description]

    if @product_unit.save!
       redirect_to :action => :index
    else
       redirect_to :action => :new
    end
    
  end

  def edit
    @product_unit = EpicsProductUnits.find(params[:product_unit])
  end

  def update
    @product_unit = EpicsProductUnits.find(params[:product_unit][:product_unit_id])
    @product_unit.name = params[:product_unit][:name]
    @product_unit.description = params[:product_unit][:description]

    if @product_unit.save!
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :product_unit_id => params[:product_unit][:product_unit_id]
    end
  end

  def void
    @product_unit = EpicsProductUnits.find(params[:product_unit_id])
    @product_unit.voided = 1
    @product_unit.save!
		render :text => 'showMsg("Record Deleted!")'
  end

end
