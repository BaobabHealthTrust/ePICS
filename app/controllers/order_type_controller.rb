class OrderTypeController < ApplicationController

  def index
    @order_types = EpicsOrderTypes.order(:name)
    render :layout => false
  end

  def new
    @order_types = EpicsOrderTypes.new()
  end

  def create
    @order_type = EpicsOrderTypes.new()
    @order_type.name = params[:order_type][:name]
    @order_type.description = params[:order_type][:description]

    if @order_type.save
       redirect_to :action => :index
    else
       redirect_to :action => :new
    end

  end

  def edit
    @order_type = EpicsOrderTypes.find(params[:order_type])
  end

  def update
    @order_type = EpicsOrderTypes.find(params[:order_type][:order_type_id])
    @order_type.name = params[:order_type][:name]
    @order_type.description = params[:order_type][:description]

    if @order_type.save
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :order_type_id => params[:order_type][:order_type_id]
    end
  end

  def void
    @order_type = EpicsOrderTypes.find(params[:order_type_id])
    @order_type.voided = 1
    @order_type.save!
		render :text => 'showMsg("Record Deleted!")'
  end

end
