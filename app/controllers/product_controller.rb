class ProductController < ApplicationController
  def index
    @products = EpicsProduct.all
    render :layout => "custom"
  end

  def view
    @product = EpicsProduct.where("name = ?",params[:product])[0]
    session[:product] = params[:product]
    render :layout => "custom"
  end

  def search
  end

  def find_by_name_or_code
    @products = EpicsProduct.where("(product_code LIKE(?) OR
      name LIKE (?))", "%#{params[:search_str]}%",
      "%#{params[:search_str]}%").limit(100).map{|product|[[product.name]]}

    render :text => "<li></li><li>" + @products.join("</li><li>") + "</li>"
  end

  def new
    @product = EpicsProduct.new
    @product_type_map = EpicsProductType.all.map{|product_type|[product_type.name,product_type.epics_product_type_id]}
    @product_unit_map = EpicsProductUnits.all.map{|product_unit|[product_unit.name,product_unit.epics_product_units_id]}
    @product_category_map = EpicsProductCategory.all.map{|product_category|[product_category.name,product_category.epics_product_category_id]}
  end

  def create
    @product = EpicsProduct.new
    @product.name = params[:product][:name]
    @product.product_code = params[:product][:product_code]
    @product.epics_product_units_id = params[:product][:product_unit_id]
    @product.epics_product_type_id = params[:product][:product_type_id]
    @product.epics_product_category_id = params[:product][:product_category_id]
    @product.expire = params[:product][:expire]
    @product.min_stock = params[:product][:min_stock]
    @product.max_stock = params[:product][:max_stock]
    @product.movement = params[:product][:movement]

    if @product.save
      redirect_to :action => :index
    else
      redirect_to :action => :new
    end
  end

  def edit
    @product = EpicsProduct.find(params[:product])
    @product_type_map = EpicsProductType.all.map{|product_type|[product_type.name,product_type.epics_product_type_id]}
    @product_unit_map = EpicsProductUnits.all.map{|product_unit|[product_unit.name,product_unit.epics_product_units_id]}
    @product_category_map = EpicsProductCategory.all.map{|product_category|[product_category.name,product_category.epics_product_category_id]}
  end

  def update
    @product = EpicsProduct.find(params[:product][:product_id])
    @product.name = params[:product][:name]
    @product.product_code = params[:product][:product_code]
    @product.epics_product_units_id = params[:product][:product_unit_id]
    @product.epics_product_type_id = params[:product][:product_type_id]
    @product.epics_product_category_id = params[:product][:product_category_id]
    @product.expire = params[:product][:expire]
    @product.min_stock = params[:product][:min_stock]
    @product.max_stock = params[:product][:max_stock]
    @product.movement = params[:product][:movement]

    if @product.save
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :product_id => params[:product][:product_id]
    end
  end

  def void
    @product = EpicsProduct.find(params[:product_id])
    @product.voided = 1
    @product.save!
		render :text => 'showMsg("Record Deleted!")'
  end

  def get_products
    #@products = EpicsProduct.where(:epics_product_category_id => params[:product_category_id]).map{|product|[[product.name]]}
    @products = EpicsProduct.where("epics_product_category_id = ? AND
      name LIKE (?)", params[:product_category_id],
      "%#{params[:search_str]}%").map{|product|[[product.name]]}

    render :text => "<li></li><li>" + @products.join("</li><li>") + "</li>"
  end

  def expire
    @expires = EpicsProduct.where(:name => params[:product_name]).first.expire
    render :text => @expires.to_s
  end

  def get_batch_details
    item = EpicsProduct.where("name=?",params[:name])[0]
    @products = []
    (item.epics_stock_details ||[]).each do |detail|
      next if (detail.epics_stock_expiry_date.blank? || (detail.current_quantity == 0))
      @products << detail.epics_stock_expiry_date.expiry_date.to_date.strftime("%d-%b-%Y")
    end
    @products = @products.sort{|x, y| x.to_date <=> y.to_date}
    @html = "<li></li><li style='color:red;'>" + @products[0] + "</li>"
    @products.delete_at(0)
    render :text => @html +"<li>" + @products.uniq.join("</li><li>") + "</li>"
  end

  def edit_product
    @product = EpicsProduct.find(params[:product_id])
    @product_type_map = EpicsProductType.all.map{|product_type|[product_type.name,product_type.epics_product_type_id]}
    @product_unit_map = EpicsProductUnits.all.map{|product_unit|[product_unit.name,product_unit.epics_product_units_id]}
    @product_category_map = EpicsProductCategory.all.map{|product_category|[product_category.name,product_category.epics_product_category_id]}
  end

  def save_edited_product
    @product = EpicsProduct.find(params[:product][:product_id])
    @product.name = params[:product][:name]
    @product.product_code = params[:product][:product_code]
    @product.epics_product_units_id = params[:product][:product_unit_id]
    @product.epics_product_type_id = params[:product][:product_type_id]
    @product.epics_product_category_id = params[:product][:product_category_id]
    @product.expire = params[:product][:expire]
    @product.min_stock = params[:product][:min_stock]
    @product.max_stock = params[:product][:max_stock]
    @product.movement = params[:product][:movement]
    if @product.save
       redirect_to :action => :view, :product =>params[:product][:name]
    else
       redirect_to :action => :edit, :product_id => params[:product][:product_id]
    end
  end

  def stock_card
    @item = EpicsProduct.find(params[:id])
    @page_title = "#{@item.name}<br />Stock Card"
    @trail = {}

    EpicsReport.receipts(@item, @trail) 
    EpicsReport.issues(@item, @trail) 
    EpicsReport.negative_adjustments(@item, @trail) 
    EpicsReport.positive_adjustments(@item, @trail) 
    raise @trail.to_yaml

=begin
          @trail[invoice_number][batch_number] = {
            :received_quantity => EpicsReport.received_quantity(stock, @item, date),
            :quantity_issued => EpicsReport.issued(stock, @item, date),
            :losses => EpicsReport.losses_quantity(stock, @item, date),
            :positive_adjustments => EpicsReport.positive_adjustments(stock, @item, date),
            :negative_adjustments => EpicsReport.negative_adjustments(stock, @item, date),
            :current_quantity => EpicsReport.current_quantity(stock,@item),
            :transaction_date => date
          }
=end
    render :layout => "report"
  end

  def edit_cost
    if request.post?
      EpicsItemCost.transaction do
        cost = EpicsItemCost.find_by_epics_products_id(params[:item]['id'])
        if cost.blank?
          cost = EpicsItemCost.new()
        else
          cost.voided = true
          cost.void_reason = 'Setting new cost'
          cost.save
          cost = EpicsItemCost.new()
        end
        cost.epics_products_id = params[:item]['id']
        cost.unit_price = params[:item]['unit_price']
        cost.pack_size = params[:item]['pack_size']
        cost.billing_charge = params[:item]['billing_charge']
        cost.save
        redirect_to :action => :view, 
          :product => EpicsProduct.find(cost.epics_products_id).name
      end
    end
    @cost = EpicsItemCost.find_by_epics_products_id(params[:id])
  end

  def stock_card_printable
    stocks = EpicsStock.joins(:epics_stock_details).where("epics_products_id =?", params[:id])
    @item = EpicsProduct.find(params[:id])
    @page_title = "#{@item.name}<br />Stock Card"
    @trail = {}

    (stocks || []).each do |stock|
      date = stock.grn_date.to_date
      grn_number = stock.grn_number

      if @trail[grn_number].blank?
        @trail[grn_number] = {}
        @trail[grn_number][date] = {}
      elsif not @trail[grn_number].blank? and @trail[grn_number][date].blank?
        @trail[grn_number][date] = {}
      end

      @trail[grn_number][date] = {
        :received_quantity => EpicsReport.received_quantity(stock, @item, date),
        :quantity_issued => EpicsReport.issued(stock, @item, date),
        :losses => EpicsReport.losses_quantity(stock, @item, date),
        :positive_adjustments => EpicsReport.positive_adjustments(stock, @item, date),
        :negative_adjustments => EpicsReport.negative_adjustments(stock, @item, date),
        :current_quantity => EpicsReport.current_quantity(stock,@item)
      }

    end
    render :layout => false
  end

  def print_stock_card
    location = request.remote_ip rescue ""
    current_printer = ""
    id = params[:id]
    locations = EpicsGlobalProperty.find("facility.printers").property_value.split(",") rescue []
    locations.each{|ward|
      current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
    } rescue []

      t1 = Thread.new{
        Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
          request.env["HTTP_HOST"] + "\"/product/stock_card_printable/" +\
          "?id=#{id}" + "\" /tmp/output-stock_card" + ".pdf \n"
      }

      file = "/tmp/output-stock_card" + ".pdf"
      t2 = Thread.new{
        sleep(3)
        print(file, current_printer)
      }
      render :text => "true" and return
  end

  def print(file_name, current_printer)
    sleep(3)
    if (File.exists?(file_name))
     Kernel.system "lp -o sides=two-sided-long-edge -o fitplot #{(!current_printer.blank? ? '-d ' + current_printer.to_s : "")} #{file_name}"
    else
      print(file_name)
    end
  end
  
end
