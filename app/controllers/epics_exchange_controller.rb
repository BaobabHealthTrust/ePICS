class EpicsExchangeController < ApplicationController

  def create

    session[:exchange] = nil
    exchange_hash = Hash.new()
    exchange_hash[:exchange_facility] = params[:facility]
    exchange_hash[:exchange_date] = params[:exchange_date]
    exchange_hash[:exchange_invoice_number] = params[:invoice_number]
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
    @page_title = "Exchange Items"
    render :layout => 'custom'
  end

  def index
    @locations = EpicsLocationType.find(:first, :conditions => ["name = 'Facility'"]).epics_locations.collect{|x| x.name }
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
      quantity = ((params[:item]['issue_quan'].blank? ? params[:item]['issue_quantity'] : params[:item]['issue_quan'] ).to_i * params[:item]['item_quantity'].to_i) rescue 1
      expiry_date = product.epics_stock_details.last.epics_stock_expiry_date.expiry_date rescue nil
      @issue_cart.add_product(product,nil,quantity,nil,expiry_date)
      @receive_cart = find_product_receive_cart
     # session[:issuing_location_id] = @location.id
      redirect_to :action => "new"
    end
  end

  def receive_item

    @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }
    @locations_map = EpicsLocationType.find(:first, :conditions => ["name = 'Store room'"]).epics_locations.collect{|x| x.name }
    @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}

    if request.post?
      @receive_cart = find_product_receive_cart
      product = EpicsProduct.find_by_name(params[:stock_details][:product_name])
      quantity = ((params[:stock_details]['issue_quan'].blank? ? params[:stock_details]['issue_quantity'] : params[:stock_details]['issue_quan'] ).to_i * params[:stock_details]['item_quantity'].to_i) rescue 1
      location = params[:stock_details][:location_id]
      expiry_date = params[:stock_details][:expiry_date]
      batch_number = params[:stock_details][:batch_number]
      @receive_cart.add_product(product,batch_number,quantity,location,expiry_date)
      @issue_cart = find_product_issue_cart
      redirect_to :action => "new"
    end

  end

  def exchange
    @received_items = find_product_receive_cart
    @issued_items = find_product_issue_cart
    @exchange_details = session[:exchange]

    order_type = EpicsOrderTypes.find_by_name('Exchange')
    EpicsExchange.transaction do
      @stock = EpicsStock.new()
      @stock.grn_date = @exchange_details[:exchange_date]
      @stock.invoice_number = @exchange_details[:exchange_invoice_number]
      @stock.epics_supplier_id = EpicsSupplier.find_by_name('Other')
      @stock.save!

      for item in @received_items.items
        @stock_detail = EpicsStockDetails.new()
        @stock_detail.epics_stock_id = @stock.epics_stock_id
        @stock_detail.epics_products_id = item.product_id
        @stock_detail.epics_location_id = params[:issue_to]
        @stock_detail.received_quantity = item.quantity
        @stock_detail.current_quantity = item.quantity
        @stock_detail.batch_number = item.batch_number
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
      @order.epics_order_type_id = order_type.id 
      @order.epics_location_id = params[:issue_to]
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

      session[:receive_copy] = session[:receive]
      session[:issue_copy] = session[:issue]
      session[:exchange_details_copy] = session[:exchange]
      exchanging = EpicsExchange.new()
      exchanging.epics_stock_id = @stock.epics_stock_id
      exchanging.epics_order_id = @order.id
      exchanging.epics_location_id = EpicsLocation.find_by_name(@exchange_details[:exchange_facility]).id
      exchanging.epics_exchange_date = @exchange_details[:exchange_date]
      exchanging.creator = User.current
      exchanging.save!

      session[:receive] = nil
      session[:issue ] = nil
      session[:exchange] = nil
      stock_id = EpicsStock.last.id
      print_exchanged_items_label(stock_id, session[:exchange_details_copy])
      #redirect_to :action => :summary,:exchange_details => @exchange_details
       #redirect_to summary({:received_items => @received_items.items,:issued_items => @issued_items.items,:exchange_details => @exchange_details})
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
        max_quantity -= e.current_quantity
      else
        stock_details << [e.id, max_quantity]
        max_quantity = 0
        break
      end
    end

    return stock_details
  end

  def summary
    #raise session[:receive_copy].to_yaml
    @received_cart = session[:receive_copy]
    @issued_cart = session[:issue_copy]
    @exchange_details = session[:exchange_details_copy] #params[:exchange_details]
    @page_title = "Exchange Items Summary"
    render :layout => 'custom'
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

  def remove_product_from_issue_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:issue]
    cart.remove_product(product)
    render :text => "true"
  end

  def remove_product_from_receive_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:receive]
    cart.remove_product(product)
    render :text => "true"
  end

  def print_exchanged_items_label(stock_id, exchange_details)
    print_and_redirect("/epics_exchange/exchange_items_label?stock_id=#{stock_id}", "/epics_exchange/summary?exchange_details=#{exchange_details}")
  end

  def print_exchanged_items_from_view
    stock_id = params[:stock_id]
    exchange_details = params[:exchange_details]
    print_and_redirect("/epics_exchange/exchange_items_label?stock_id=#{stock_id}", "/epics_exchange/summary?exchange_details=#{exchange_details}")
  end

  def exchange_items_label
    stock_id = params[:stock_id]
    print_string = exchange_items_data(stock_id)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{Time.now.to_i}.lbl", :disposition => "inline")
  end

  def exchange_items_data(stock_id)
      label = ZebraPrinter::StandardLabel.new
      label.font_size = 3
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 50
      stock = EpicsStock.find(stock_id)
      stock_details = EpicsStockDetails.find_all_by_epics_stock_id(stock_id)
      exchange_location_id = EpicsExchange.last(:conditions => ["epics_stock_id =?",
          stock_id]).epics_location_id
      facility_name = EpicsLocation.find(exchange_location_id).name
      label.draw_multi_text("Exchanged Items(Received): Delivered on #{stock.grn_date.to_date.strftime('%d-%b-%Y')}", :font_reverse => true)
      label.draw_multi_text("Facility Name: #{facility_name}", :font_reverse => false)
      label.draw_multi_text("Invoice Number: #{stock.invoice_number}", :font_reverse => false)
      label.draw_multi_text("Stock Details", :font_reverse => true)
      stock_details.each do |stock_detail|
        label.draw_multi_text("#{stock_detail.epics_product.name + ' ' + stock_detail.received_quantity.to_s +
          ' ' + stock_detail.epics_product.epics_product_units.name}",
          :font_reverse => false)
      end
      user_name = User.current.openmrs_person.openmrs_person_names[0]
      user_name = user_name.given_name.first.capitalize + '.' + user_name.family_name
      label.draw_multi_text("Processed By: #{user_name}", :font_reverse => true)
      label.print(1)
  end
end
