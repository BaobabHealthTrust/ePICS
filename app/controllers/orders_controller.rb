class OrdersController < ApplicationController
  def index
  end

  def new
    @order = EpicsOrderTypes.all.map{|order| [order.name,order.epics_order_type_id]}
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
