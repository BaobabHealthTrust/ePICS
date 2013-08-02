class SupplierTypeController < ApplicationController
  
  def create
    EpicsSupplierType.transaction do
      type = EpicsSupplierType.new()
      type.name = params[:supplier_type]['name']
      type.description = params[:supplier_type]['description']
      if type.save
         flash[:notice] = "Successfully created."
        redirect_to :action => :index and return
      else
         flash.now[:error] = 'Failed to add.'
        redirect_to :action => :new and return
      end 
    end
  end

  def index
    @supplier_types = EpicsSupplierType.order(:name)
    render :layout => "custom"
  end

  def new
     @supplier_type = EpicsSupplierType.new()
  end

  def edit
    @supplier_type = EpicsSupplierType.find(params[:supplier_type])
  end

  def update
    @supplier_type = EpicsSupplierType.find(params[:supplier_type][:supplier_type_id])
    @supplier_type.name = params[:supplier_type][:name]
    @supplier_type.description = params[:supplier_type][:description]

    if @supplier_type.save
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :supplier_type_id => params[:supplier_type][:supplier_type_id]
    end
  end

  def void
    @supplier_type = EpicsSupplierType.find(params[:supplier_type_id])
    @supplier_type.voided = 1
    @supplier_type.save!
		render :text => 'showMsg("Record Deleted!")'
  end

end
