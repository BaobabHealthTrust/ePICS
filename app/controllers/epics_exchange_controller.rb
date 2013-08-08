class EpicsExchangeController < ApplicationController

  def create

    session[:exchange] = nil
    exchange_hash = Hash.new()
    exchange_hash[:exchange_facility] = params[:location]
    exchange_hash[:exchange_date] = params[:exchange_date]
    exchange_hash[:exchange_batch_id] = params[:batch_number]
    session[:exchange] = exchange_hash

    unless session[:exchange].nil?
      redirect_to :controller => :epics_exchange, :action => :new
    else
      redirect_to :action => :new
    end


  end

  def new
    @issue_cart = find_product_issue_cart
    @receive_cart = find_product_receive_cart
    
    render :layout => 'custom'
  end

  def index

  end

  def give_item
     @product_category_map = EpicsProductCategory.all.map do |product_category|
      [product_category.name,product_category.epics_product_category_id]
    end
     @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }
    
    if request.post?
      @location = EpicsLocation.find_by_name(params['location'])
      @issue_cart = find_product_issue_cart
      product = EpicsProduct.where("name = ?",params[:item]['name'])[0]
      quantity = params[:item]['quantity'].to_f
      expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
      @issue_cart.add_product(product,quantity,nil,expiry_date)
      @receive_cart = find_product_receive_cart
     # session[:issuing_location_id] = @location.id
      redirect_to :action => "new"
    end
  end

  def receive_item

    @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }
    @locations_map = EpicsLocation.all.map{|location| [location.name,location.epics_location_id]}
    @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}

    if request.post?
      @receive_cart = find_product_receive_cart
      product = EpicsProduct.find_by_name(params[:stock_details][:product_name])
      quantity = params[:stock_details][:quantity].to_f
      location = params[:stock_details][:location_id]
      expiry_date = params[:stock_details][:expiry_date]
      @receive_cart.add_product(product,quantity,location,expiry_date)
      @issue_cart = find_product_issue_cart
      redirect_to :action => "new"
    end

  end

  def exchange
    @received_items = find_product_receive_cart
    @issued_items = find_product_issue_cart
    @exchange_details = session[:exchange]

    order_type = EpicsOrderTypes.find_by_name('Dispense')
    EpicsExchange.transaction do


      @stock = EpicsStock.new()
      @stock.grn_date = @exchange_details[:exchange_date]
      @stock.grn_number = @exchange_details[:exchange_batch_id]
      @stock.epics_supplier_id = @exchange_details[:exchange_facility]
      @stock.save!

      for item in @received_items.items
        @stock_detail = EpicsStockDetails.new()
        @stock_detail.epics_stock_id = @stock.epics_stock_id
        @stock_detail.epics_products_id = item.product_id
        @stock_detail.epics_location_id = item.location
        @stock_detail.received_quantity = item.quantity
        @stock_detail.current_quantity = item.quantity
        @stock_detail.epics_product_units_id = item.product.epics_product_units_id
        @stock_detail.save!

        unless item.expiry_date.blank?
          @stock_expiry_dates = EpicsStockExpiryDates.new()
          @stock_expiry_dates.epics_stock_details_id = @stock_detail.epics_stock_details_id
          @stock_expiry_dates.expiry_date = item.expiry_date
          @stock_expiry_dates.save!
        end
      end


      @order = EpicsOrders.new()
      @order.epics_order_type_id = order_type.id rescue 1
      @order.save

      (@issued_items.items || {}).each do |item, values|
        get_stock_detail(item.name , item.quantity).each do |stock_id , quantity|
          item_order = EpicsProductOrders.new()
          item_order.epics_order_id = @order.id
          item_order.epics_stock_details_id = stock_id
          item_order.quantity = quantity
          item_order.save
          update_stock_details(stock_id, quantity)
        end
      end



      session[:receive] = nil
      session[:issue ] = nil
      session[:exchange] = nil

      render :action => :summary, :layout => 'custom'

    end

  end

  def get_stock_detail(name, value)
    details = EpicsStockDetails.joins("INNER JOIN epics_products e
      ON e.epics_products_id = epics_stock_details.epics_products_id").where("e.name" => name)

    max_quantity = value
    stock_details = []

    (details || []).each do |e|
      next if e.current_quantity < 1
      break if max_quantity == 0
      if e.current_quantity <= max_quantity
        stock_details << [e.id, e.current_quantity]
        max_quantity -= e.quantity
      else
        stock_details << [e.id, max_quantity]
        max_quantity = 0
        break
      end
    end

    return stock_details
  end

  def update_stock_details(stock_id, quantity)

    old_stock = EpicsStockDetails.find(stock_id)

    old_stock.current_quantity = (old_stock.current_quantity - quantity)
    old_stock.save
  end

  def find_product_issue_cart
   session[:issue] ||= ProductCart.new
  end

  def find_product_receive_cart
   session[:receive] ||= ProductCart.new
  end

end
