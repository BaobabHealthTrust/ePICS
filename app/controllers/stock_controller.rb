class StockController < ApplicationController
  def index
  end

  def new
    @supplier_map = EpicsSupplier.all.map{|supplier| [supplier.name, supplier.epics_supplier_id]}
  end

  def create
    
  end

  def edit
  end

  def update
  end

  def void
  end

end
