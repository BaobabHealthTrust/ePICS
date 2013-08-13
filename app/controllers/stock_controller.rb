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

  def remove_product_from_borrow_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:borrow_cart]
    cart.remove_product(product)
    render :text => "true"
 end

  def get_batches_not_reimbursed_to_facility

    loans = EpicsLendsOrBorrows.find(:all,
                                     :conditions => ["epics_lends_or_borrows_type_id = ? AND reimbursed = false AND facility = ? ",
                                      EpicsLendsOrBorrowsType.find_by_name(params[:type]).id,
                                      EpicsLocation.find_by_name(params[:facility]).id])

    batches = EpicsStock.find(:all, :conditions => ["epics_stock_id IN (?)", loans.collect{|c| c.epics_stock_id}]).collect{|x| x.grn_number}

    render :text => "<li></li><li>" + batches.join("</li><li>") + "</li>"
  end

end
