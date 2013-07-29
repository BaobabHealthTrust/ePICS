class SupplierController < ApplicationController

  def index
    @suppliers = EpicsSupplier.order(:name)
    render :layout => false
  end

  def new
     @supplier = EpicsSupplier.new()
     @supplier_type_map = EpicsSupplierType.all.map{|supplier_type|[supplier_type.name,supplier_type.epics_supplier_type_id]}
  end

  def create
    @supplier = EpicsSupplier.new()
    @supplier.name = params[:supplier][:name]
    @supplier.address = params[:supplier][:address]
    @supplier.phone_number = params[:supplier][:phone_number]
    @supplier.local = params[:supplier][:local]
    @supplier.epics_supplier_type_id = params[:supplier][:supplier_type_id]
    @supplier.description = params[:supplier][:description]
 
    if @supplier.save
      redirect_to :action => :index
    else
      redirect_to :action => :new
    end
  end

  def edit
    @supplier = EpicsSupplier.find(params[:supplier])
    @supplier_type_map = EpicsSupplierType.all.map{|supplier_type|[supplier_type.name,supplier_type.epics_supplier_type_id]}
  end

  def update
    @supplier = EpicsSupplier.find(params[:supplier][:supplier_id])
    @supplier.name = params[:supplier][:name]
    @supplier.address = params[:supplier][:address]
    @supplier.phone_number = params[:supplier][:phone_number]
    @supplier.local = params[:supplier][:local]
    @supplier.epics_supplier_type_id = params[:supplier][:supplier_type_id]
    @supplier.description = params[:supplier][:description]

    if @supplier.save
      redirect_to :action => :index
    else
      redirect_to :action => :new
    end
  end

  def void
    @supplier = EpicsSupplier.find(params[:supplier_id])
    @supplier.voided = 1
    @supplier.save!
		render :text => 'showMsg("Record Deleted!")'
  end

end
