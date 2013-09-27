class StockDetailsController < ApplicationController


  def index
    @cart = find_product_cart
    @page_title = "Receiving Items"
    render :layout => "custom"
  end

  def new
    unless session[:stock].nil?
      @stock_detail = EpicsStockDetails.new()
      @locations_map = EpicsLocation.find(:all, :conditions => ["epics_location_type_id = ? ",
                                                   EpicsLocationType.find_by_name("Store room").id ]).map{|location| [location.name,location.epics_location_id]}
      @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}
      @product_expire_details = {}
      epics_products = EpicsProduct.all
      epics_products.map{|product| @product_expire_details[product.name] = product.expire }
    end
  end

  def create
    @cart = find_product_cart
    product = EpicsProduct.find_by_name(params[:stock_details][:product_name])
    quantity = ((params[:stock_details]['issue_quan'].blank? ? params[:stock_details]['issue_quantity'] : params[:stock_details]['issue_quan'] ).to_i * params[:stock_details]['item_quantity'].to_i) rescue 1
    location = params[:stock_details][:location_id]
    expiry_date = params[:stock_details][:expiry_date]
    batch_number = params[:stock_details][:batch_number]
    @cart.add_product(product,batch_number,quantity,location,expiry_date)

    redirect_to :action => :index
  end

  def edit
  end

  def update
  end

  def void
   stock_id = params[:stock_id]
   reason = params[:reason]
   stock = EpicsStockDetails.find(stock_id)
   stock.voided = 1
   stock.void_reason = reason
   stock.voided_by = session[:user_id]
   stock.save!
   render :text => "done"
  end

  def board_off_stock
    stock_id = params[:stock_id]
    reason = params[:reason]
    board_off_quantity = params[:board_off_quantity].to_f rescue 0

    stock = EpicsStockDetails.find(stock_id)

    if stock.current_quantity > 0 
      if stock.current_quantity >= board_off_quantity 
        ActiveRecord::Base.transaction do
          location_type = EpicsLocationType.find_by_name('Medication Disposal')
          epics_location = EpicsLocation.find_by_epics_location_type_id(location_type.id)
          order_type = EpicsOrderTypes.find_by_name('Board off')
          epics_order = EpicsOrders.new
          epics_order.epics_order_type_id = order_type.id
          epics_order.epics_location_id = epics_location.id
          epics_order.instructions = reason
          epics_order.save!

          product_order = EpicsProductOrders.new
          product_order.epics_order_id = epics_order.id
          product_order.epics_stock_details_id = stock.id
          product_order.quantity = stock.current_quantity
          product_order.save!

          stock.current_quantity = board_off_quantity
          stock.save
        end
      end
    end
    render :text => "done"
  end
  
  def checkout


    type = ActiveSupport::JSON.decode params[:type] rescue nil
    if params[:type].blank?
      stock = session[:stock]
      stock_details = find_product_cart
    elsif type == 'borrow'
      stock = session[:borrow]
      stock_details = (session[:borrow_cart] ||= ProductCart.new)
    elsif type == 'return'
      stock = session[:item_returns]
      stock_details = (session[:return_items] ||= ProductCart.new)
    end

    unless stock.nil?
      unless stock_details.nil?
        EpicsStock.transaction do
          
          @stock = EpicsStock.new()
          @stock.grn_date = stock[:grn_date]
          @stock.invoice_number = stock[:invoice_number]
          @stock.epics_supplier_id = stock[:supplier_id]
          @stock.save!


          @witness = EpicsWitnessNames.new
          @witness.epics_stock_id = @stock.epics_stock_id
          @witness.name = stock[:witness_names]
          @witness.save!


          if type.eql?('borrow')

            lend = EpicsLendsOrBorrows.new
            lend.epics_stock_id = @stock.id
            lend.facility = EpicsLocation.find_by_name(stock[:borrowing_from]).id
            lend.lend_or_borrow_date = stock[:grn_date]
            lend.epics_lends_or_borrows_type_id = EpicsLendsOrBorrowsType.find_by_name("borrow").id
            lend.return_date = stock[:return_date]
            lend.save

            authorizer = EpicsLendBorrowAuthorizer.new
            authorizer.authorizer = stock[:authorizer]
            authorizer.epics_lends_or_borrows_id = lend.id
            authorizer.save

          elsif type.eql?('return')

            returning = EpicsLendsOrBorrows.find(stock[:loan_id])
            returning.epics_stock_id = @stock.epics_stock_id
            returning.reimbursed = true
            returning.save

          end

          for item in stock_details.items
            @stock_detail = EpicsStockDetails.new()
            @stock_detail.epics_stock_id = @stock.epics_stock_id
            @stock_detail.epics_products_id = item.product_id
            @stock_detail.epics_location_id = item.location
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

          if type.eql?('borrow')
            session[:borrow] = session[:borrow_cart] = nil
            print_borrowed_items_label(@stock.epics_stock_id, type)
          elsif type.eql?('return')
            session[:item_returns] = session[:return_items] = nil
            print_received_back_items_label(@stock.epics_stock_id, type)
          else
            session[:cart] = session[:stock] = nil
            print_received_items_label(@stock.epics_stock_id, type)
          end
          #print_received_items_label(@stock.epics_stock_id)#print and redirect inside
          #redirect_to :action => :summary, :stock_id => @stock.epics_stock_id, :type => type
        end
      end
    end
    
  end

  def borrow
    @locations_map = EpicsLocation.find(:all, :conditions => ["epics_location_type_id = ? ",
                                                              EpicsLocationType.find_by_name("Store room").id ]).map{|location| [location.name,location.epics_location_id]}
    @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}
    @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }

    if request.post?
      @borrow_cart =  (session[:borrow_cart] ||= ProductCart.new)
      product = EpicsProduct.find_by_name(params[:stock_details][:product_name])
      quantity = ((params[:stock_details]['issue_quan'].blank? ? params[:stock_details]['issue_quantity'] : params[:stock_details]['issue_quan'] ).to_i * params[:stock_details]['item_quantity'].to_i) rescue 1
      location = params[:stock_details][:location_id]
      expiry_date = params[:stock_details][:expiry_date]
      batch_number = params[:stock_details][:batch_number]
      @borrow_cart.add_product(product,batch_number,quantity,location,expiry_date)

      redirect_to "/stock/borrow_index"
    end

  end

  def summary
    @stock = EpicsStock.find(params[:stock_id])
    @stock_details = EpicsStockDetails.find_all_by_epics_stock_id(params[:stock_id])
    @page_title = "Receiving Items Summary"
    render :layout => "custom"
  end

  def remove_product_from_cart
    product_id = params[:product_id]
    product = EpicsProduct.find(product_id)
    cart = session[:cart]
    cart.remove_product(product)
    render :text => "true"
  end


  def return_index

    @return_cart = session[:return_items] ||= ProductCart.new

    if !params[:id].blank?
      session[:item_returns][:loan_id] = EpicsLendsOrBorrows.find_by_epics_orders_id(params[:id]).id
    end

    if request.post?
      @return_cart =  (session[:return_items] ||= ProductCart.new)
      product = EpicsProduct.find_by_name(params[:stock_details][:product_name])
      quantity = ((params[:stock_details]['issue_quan'].blank? ? params[:stock_details]['issue_quantity'] : params[:stock_details]['issue_quan'] ).to_i * params[:stock_details]['item_quantity'].to_i) rescue 1
      location = params[:stock_details][:location_id]
      expiry_date = params[:stock_details][:expiry_date]
      batch_number = params[:stock_details][:batch_number]
      @return_cart.add_product(product,batch_number,quantity,location,expiry_date)
    end
    @page_title = "Returning Borrowed Items"
    render :layout => "custom"
  end


  def return_item

    @locations_map = EpicsLocation.find(:all, :conditions => ["epics_location_type_id = ? ",
                                                              EpicsLocationType.find_by_name("Store room").id ]).map{|location| [location.name,location.epics_location_id]}
    @product_category_map = EpicsProductCategory.all.map{|category| [category.name, category.epics_product_category_id]}
    @product_expire_details = {}
    epics_products = EpicsProduct.all
    epics_products.map{|product| @product_expire_details[product.name] = product.expire }

  end

  def board_off
    stock = EpicsStockDetails.find(params[:stock_detail_id])
    stock.voided = true
    stock.void_reason = "Expired"
    render :text => stock.save and return
  end

  def edit_stock_details
    stock_details = EpicsStockDetails.find(params[:stock_id])
    session[:epics_stock_details] = stock_details
    render :layout=> "application"
  end

  def save_edited_stock_details
    stock_details = session[:epics_stock_details]
    session[:epics_stock_details] = nil
    units = params[:units].delete_if{|value|value.blank? || value.match(/Other/i)}.to_s.to_i
    quantity = params[:quantity].to_i
    reason = params[:reason]
    received_quantity = units * quantity
    prev_stock = EpicsStockDetails.find(stock_details.id)
    prev_received_quantity = prev_stock.received_quantity
    difference = received_quantity - prev_received_quantity
    ActiveRecord::Base.transaction do
        old_stock = EpicsStockDetails.find(stock_details.id)
        old_stock.received_quantity = received_quantity
        old_stock.current_quantity = (old_stock.current_quantity) + difference
        old_stock.save!
        EpicsStockDetails.create!(
          :epics_stock_id => stock_details.epics_stock_id,
          :epics_products_id => stock_details.epics_products_id,
          :received_quantity => stock_details.received_quantity,
          :epics_product_units_id => stock_details.epics_product_units_id,
          :epics_location_id => stock_details.epics_location_id,
          :voided => 1,
          :voided_by => session[:user_id],
          :void_reason => reason
        )
    end
    redirect_to :controller => "product", :action => "view", :product => session[:product]
  end
#********************************************************************************
  def print_received_items_label(stock_id, type)
    print_and_redirect("/stock_details/receive_items_label?stock_id=#{stock_id}", "/stock_details/summary?stock_id=#{stock_id}&type=#{type}")
  end

  def print_received_items_from_view
    stock_id = params[:stock_id]
    type = params[:type]
    print_and_redirect("/stock_details/receive_items_label?stock_id=#{stock_id}", "/stock_details/summary?stock_id=#{stock_id}&type=#{type}")
  end
  
  def receive_items_label
    stock_id = params[:stock_id]
    print_string = receive_items_data(stock_id)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{Time.now.to_i}.lbl", :disposition => "inline")
  end
  
  def receive_items_data(stock_id)
      label = ZebraPrinter::StandardLabel.new
      label.font_size = 3
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 50
      stock = EpicsStock.find(stock_id)
      stock_details = EpicsStockDetails.find_all_by_epics_stock_id(stock_id)
      label.draw_multi_text("Received Items: Delivered on #{stock.grn_date.to_date.strftime('%d-%b-%Y')}", :font_reverse => true)
      label.draw_multi_text("Supplier Name: #{stock.epics_supplier.name}", :font_reverse => false)
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
#*******************************************************************************
  def print_borrowed_items_label(stock_id, type)
    print_and_redirect("/stock_details/borrow_items_label?stock_id=#{stock_id}", "/stock_details/summary?stock_id=#{stock_id}&type=#{type}")
  end

  def print_borrowed_items_from_view
    stock_id = params[:stock_id]
    type = params[:type]
    print_and_redirect("/stock_details/borrow_items_label?stock_id=#{stock_id}", "/stock_details/summary?stock_id=#{stock_id}&type=#{type}")
  end
  
  def borrow_items_label
    stock_id = params[:stock_id]
    print_string = borrow_items_data(stock_id)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{Time.now.to_i}.lbl", :disposition => "inline")
  end
  
  def borrow_items_data(stock_id)
      label = ZebraPrinter::StandardLabel.new
      label.font_size = 3
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 50
      stock = EpicsStock.find(stock_id)
      stock_details = EpicsStockDetails.find_all_by_epics_stock_id(stock_id)
      label.draw_multi_text("Borrowed Items: Delivered on #{stock.grn_date.to_date.strftime('%d-%b-%Y')}", :font_reverse => true)
      label.draw_multi_text("Supplier Name: #{stock.epics_supplier.name}", :font_reverse => false)
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
#*******************************************************************************
  def print_received_back_items_label(stock_id, type)
    print_and_redirect("/stock_details/receive_back_items_label?stock_id=#{stock_id}", "/stock_details/summary?stock_id=#{stock_id}&type=#{type}")
  end

  def print_received_back_items_from_view
    stock_id = params[:stock_id]
    type = params[:type]
    print_and_redirect("/stock_details/receive_back_items_label?stock_id=#{stock_id}", "/stock_details/summary?stock_id=#{stock_id}&type=#{type}")
  end

  def receive_back_items_label
    stock_id = params[:stock_id]
    print_string = receive_back_items_data(stock_id)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{Time.now.to_i}.lbl", :disposition => "inline")
  end

  def receive_back_items_data(stock_id)
      label = ZebraPrinter::StandardLabel.new
      label.font_size = 3
      label.font_horizontal_multiplier = 1
      label.font_vertical_multiplier = 1
      label.left_margin = 50
      stock = EpicsStock.find(stock_id)
      stock_details = EpicsStockDetails.find_all_by_epics_stock_id(stock_id)
      label.draw_multi_text("Received Back Items: Delivered on #{stock.grn_date.to_date.strftime('%d-%b-%Y')}", :font_reverse => true)
      label.draw_multi_text("Supplier Name: #{stock.epics_supplier.name}", :font_reverse => false)
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
#*******************************************************************************
  def exchange_items_label()

  end

  def void_transaction                                                          
    render :text => "#{params[:transaction]}  Works!!!!" and return         
    
    transaction = params[:transaction].upcase                            
    product_id = params[:product_id]

    if transaction == 'BOARD OFF' || transaction == 'ISSUES'                                   
      transaction_id = params[:epics_product_order_id]                   
      revert_issue(transaction_id)             
    elsif transaction.match(/POSITIVE_ADJUSTMENTS:EXCHANGE/i)       
      revert_positive_adjustments(params[:epics_stock_details_id], product_id, transaction)                  
    elsif transaction.match(/POSITIVE_ADJUSTMENTS:BORROW/i)         
      revert_positive_adjustments(params[:epics_stock_details_id], product_id, transaction)                  
    elsif transaction.match(/NEGATIVE_ADJUSTMENTS/i)                
      transaction_id = params[:epics_product_order_id]                   
    elsif transaction == 'RECEIPTS'                                 
      transaction_id = params[:epics_stock_details_id]                   
    end
 
    render :text => "Reverted ...." and return         
  end
          
  protected
 
  # ......................................................................... 

  def revert_positive_adjustments(epics_lends_or_borrows_id, product_id, transaction_name)
    if transaction_name == 'POSITIVE_ADJUSTMENTS:BORROW'
      EpicsLendsOrBorrows.transaction do 
        epics_lends_or_borrows = EpicsLendsOrBorrows.find(epics_lends_or_borrows_id)
        epics_lends_or_borrows.voided = 1
        epics_stock_id = epics_lends_or_borrows.epics_stock_id
        epics_order_id = epics_lends_or_borrows.epics_order_id
        epics_lends_or_borrows.save
  
        unless epics_order_id.blank?
          epics_stock_details_id = EpicsProductOrders.joins("INNER JOIN epics_stock_details s
            ON s.epics_stock_details_id = epics_product_orders.epics_stock_details_id
            AND s.voided = 0").where("epics_order_id = ? AND s.epics_products_id = ?",
            epics_order_id, product_id).first.epics_stock_details_id rescue nil

          unless epics_stock_details_id.blank?
            EpicsProductOrders.where(:epics_stock_details_id => epics_stock_details_id).update_all(:voided => true)
          end

          if EpicsOrders.find(epics_order_id).epics_product_orders.blank?
            EpicsOrders.where(:epics_order_id => epics_order_id).update_all(:voided => true)
          end
        end

        unless epics_stock_id.blank?
          epics_stock = EpicsStock.find(epics_stock_id)
          if epics_stock.epics_stock_details.blank?
            epics_stock.voided = 1
            epics_stock.save
          end
        end

      end
    
    elsif transaction_name == 'POSITIVE_ADJUSTMENTS:EXCHANGE'
      EpicsExchange.transaction do
        exchange = EpicsExchange.find(epics_lends_or_borrows_id)
        epics_stock_id = exchange.epics_stock_id
        epics_order_id = exchange.epics_order_id

        epics_product_orders = EpicsProductOrders.joins("INNER JOIN epics_stock_details s 
          ON s.epics_stock_details_id = epics_product_orders.epics_stock_details_id
          AND s.voided = 0").where("epics_order_id = ? AND epics_products_id = ?",
          epics_order_id, product_id) 

        (epics_product_orders || []).each do |product_order|
          quantity = product_order.quantity 
          stock_details_id = product_order.epics_stock_details_id

          epics_stock_detail = EpicsStockDetails.find(stock_details_id)
          epics_stock_detail.current_quantity += quantity
          epics_stock_detail.save          
        end

        unless epics_product_orders.blank?
          EpicsProductOrders.where("epics_product_order_id IN(?)", 
          epics_product_orders.map(&:epics_product_order_id)).update_all(:voided => true)
        end

        if EpicsOrders.where(:epics_order_id => epics_order_id).epics_product_orders.blank?
          EpicsOrders.where(:epics_order_id => epics_order_id).update_all(:voided => true)
        end

        epics_product_orders = EpicsProductOrders.joins("INNER JOIN epics_stock_details s 
          ON s.epics_stock_details_id = epics_product_orders.epics_stock_details_id
          AND s.voided = 0").where("epics_order_id = ? AND epics_products_id <> ?",
          epics_order_id, product_id) 
        
        unless epics_product_orders.blank?
          #call delete receipts and void exchange record
        end
      end 


    end
  end

  def revert_issue(epics_product_order_id)
    EpicsProductOrders.ransaction do 
      epics_product_order = EpicsProductOrders.find(epics_product_order_id)
      epics_product_order.voided = 1
      quantity = epics_product_order.quantity
      epics_order_id = epics_product_order.epics_order_id
      epics_stock_details_id = epics_product_order.epics_stock_details_id
      epics_product_order.save

      epics_order = EpicsOrders.find(epics_order_id)
      if epics_order.epics_product_orders.blank?
        epics_order.voided = 1
        epics_order.save
      end
  
      epics_stock_detail = EpicsStockDetails.find(epics_stock_details_id)
      epics_stock_detail.current_quantity += quantity
      epics_stock_detail.save
    end
  end













  # ......................................................................... 
  def find_product_cart
    session[:cart] ||= ProductCart.new
  end

end
