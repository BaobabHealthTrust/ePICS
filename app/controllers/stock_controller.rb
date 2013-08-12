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

  def borrow
    @supplier_map =  EpicsLocationType.find(:first, :conditions => ["name = 'facility'"]).epics_locations.collect{|x| x.name }
  end

  def borrow_index

    @borrow_cart =  (session[:borrow_cart] ||= ProductCart.new)

    if request.post?
      session[:borrow] = nil
      fname = params[:authorizer].split(" ")[0].squish!
      lname = params[:authorizer].split(" ")[1].squish!
      person = EpicsPerson.where("fname = ? AND lname = ?",fname,lname ).first.id
      borrow_hash = Hash.new()
      borrow_hash[:borrowing_from] = params[:facility]
      borrow_hash[:supplier_id] = EpicsSupplier.find_by_name("Other facility").id
      borrow_hash[:grn_number] = params[:grn_number]
      borrow_hash[:authorizer] = person
      borrow_hash[:grn_date] = params[:borrow_date]
      borrow_hash[:return_date] = params[:return_date]
      borrow_hash[:witness_names] = params[:witness_name]
      session[:borrow] = borrow_hash

    end

    render :layout => "custom"

  end

  def receive_loan_returns

  end

  def get_witness_names
    names = EpicsPerson.get_names(params[:search_string])

    render :text => "<li></li><li>" + names.uniq.join("</li><li>") + "</li>"
  end

end
