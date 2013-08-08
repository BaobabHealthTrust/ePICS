class StockController < ApplicationController
  def index
  end

  def new
    @supplier_map = EpicsSupplier.all.map{|supplier| [supplier.name, supplier.epics_supplier_id]}
    @people = EpicsPerson.all.map{|person| [[person.fname+" "+ person.lname]]}

  end

  def create
    
    session[:stock] = nil
    stock_hash = Hash.new()
    stock_hash[:supplier_id] = params[:stock][:supplier_id]
    stock_hash[:grn_number] = params[:stock][:grn_number]
    stock_hash[:grn_date] = params[:stock][:grn_date]
    stock_hash[:witness_names] = params[:stock][:witness_names]
    session[:stock] = stock_hash

    unless session[:stock].nil?
      redirect_to :controller => :stock_details, :action => :new
    else
      redirect_to :action => :new
    end
  end

  def edit
  end

  def update
  end

  def void
  end

  def get_witness_names
    names = EpicsPerson.get_names(params[:search_string])

    render :text => "<li></li><li>" + names.uniq.join("</li><li>") + "</li>"
  end

end
