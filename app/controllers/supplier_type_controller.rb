class SupplierTypeController < ApplicationController
  def index
  end

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

end
