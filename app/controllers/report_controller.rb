class ReportController < ApplicationController

  def audit
    start_date = params[:date]['start'].to_date
    end_date = params[:date]['end'].to_date
    @page_title = "Audit report:<br />" + start_date.strftime('%d %b, %Y') 
    @page_title += " to " + end_date.strftime('%d %b, %Y') 
    @audits = EpicsReport.audit(start_date, end_date)
  end

  def received_items
    start_date = params[:date]['start'].to_date
    end_date = params[:date]['end'].to_date
    @page_title = "Received/Issued:<br />" + start_date.strftime('%d %b, %Y') 
    @page_title += " to " + end_date.strftime('%d %b, %Y')
    @received_items = EpicsReport.received_items(start_date,end_date) 
  end

  def view_alerts
    @alerts = EpicsReport.alerts
  end

  def alerts
    case params[:name]
      when 'Items below minimum stock'
        @alerts = EpicsStockDetails.joins("
          INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
          LEFT JOIN epics_stock_expiry_dates x ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id
        ").group('epics_stock_details.epics_products_id').select("p.product_code code,p.name name, 
        SUM(current_quantity) quantity, min_stock,epics_stock_details.batch_number batch_number,
        max_stock,expiry_date").having("quantity > 0 AND quantity < min_stock").order("p.product_code,p.name,MIN(expiry_date)")
      when 'Out of stock items'
        @alerts = EpicsStockDetails.joins("
          INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
        ").group('p.epics_products_id').select("p.product_code code,p.name name, 
        SUM(current_quantity) quantity, min_stock,max_stock").having("quantity <= 0").order("p.product_code,p.name")
      when 'Missing items'
        redirect_to :action => :missing_items
      when 'Expired items'
        @alerts = EpicsStockExpiryDates.joins("
          INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
          INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id AND p.expire = 1
          ").where("DATEDIFF(expiry_date,CURRENT_DATE()) <= 0
          AND current_quantity > 0").select("p.product_code code,p.name name, s.batch_number batch_number,
          current_quantity quantity, min_stock, max_stock, expiry_date").order("p.product_code,p.name,expiry_date")
      when 'Items expiring in the next 6 months'
        @alerts = EpicsStockExpiryDates.joins("
          INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
          INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id AND p.expire = 1
          ").where("DATEDIFF(expiry_date,CURRENT_DATE())
          BETWEEN 1 AND 183 AND current_quantity > 0").select("p.product_code code,p.name name, 
          current_quantity quantity, min_stock, s.batch_number batch_number,
          max_stock, expiry_date").order("p.product_code,p.name,expiry_date")
    end
  end

  def missing_items
    order_type = EpicsOrderTypes.find_by_name('Board Off')
    @items = {}
        
    EpicsOrders.joins("INNER JOIN epics_product_orders p                        
    ON p.epics_order_id = epics_orders.epics_order_id AND p.voided = 0          
    AND epics_orders.epics_order_type_id = #{order_type.id}                     
    INNER JOIN epics_stock_details s                                            
    ON s.epics_stock_details_id = p.epics_stock_details_id AND s.voided = 0     
    INNER JOIN epics_stocks e ON e.epics_stock_id = s.epics_stock_id            
    AND e.voided = 0 AND instructions = 'missing' INNER JOIN epics_products ep 
    ON ep.epics_products_id = s.epics_products_id
    LEFT JOIN epics_stock_expiry_dates x 
    ON x.epics_stock_details_id = s.epics_stock_details_id").select("s.epics_stock_details_id,
    ep.product_code code,ep.name,s.batch_number,s.updated_at,s.received_quantity,
    epics_orders.instructions, p.quantity went_missing,x.expiry_date").map do |r|            
      expiry_date = r.expiry_date.to_date.strftime('%d %b, %Y') rescue 'N/A'
      @items[r.epics_stock_details_id] = {:batch_number => r.batch_number, 
       :code => r.code, :name => r.name, :difference => r.went_missing,
       :updated_on => r.updated_at.to_date.strftime('%d %b, %Y') , 
       :instruction => r.instructions , 
       :received_quantity => r.received_quantity, :expiry_date => expiry_date
      }
    end

    @page_title = "Missing Items"
  end

  def select_store
    @report_name = params[:report]
    @report_name = 'store_room' if @report_name.blank?
    @store_rooms =  EpicsLocation.find(:all, :conditions => ["epics_location_type_id = ? ",
                                                             EpicsLocationType.find_by_name("Store room").id ]).map{|location| [location.name,location.epics_location_id]}
    render :layout => 'application'
  end

  def store_room
    location = EpicsLocation.find(params[:store_room])
    @page_title = "#{location.name}"

    @epics_products = EpicsProduct.joins("INNER JOIN epics_stock_details s
      ON s.epics_products_id = epics_products.epics_products_id").where("s.epics_location_id = ?",
      location.id).select("epics_products.* , s.*").group("s.epics_products_id")
  end

  def store_room_printable
    location = EpicsLocation.find(params[:store_room])
    @page_title = "#{location.name}"

    @epics_products = EpicsProduct.joins("INNER JOIN epics_stock_details s
      ON s.epics_products_id = epics_products.epics_products_id").where("s.epics_location_id = ?",
      location.id).select("epics_products.* , s.*").group("s.epics_products_id")
    
    render :layout =>false
  end
  
  def drug_availability
    location = EpicsLocation.find(params[:store_room])
    @page_title = "#{location.name}<br />Drug availability"
    @items = {}
    
    EpicsStockDetails.joins("INNER JOIN epics_products p
      ON p.epics_products_id = epics_stock_details.epics_products_id
      LEFT JOIN epics_stock_expiry_dates x 
      ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id 
      ").where("epics_stock_details.epics_location_id = ?",location.id).select("p.* , 
      epics_stock_details.*, x.*").group('epics_stock_details.epics_stock_details_id').map do |r|
      if @items[r.name].blank?
        @items[r.name] = {}
      end
      
      if @items[r.name][r.epics_stock_details_id].blank?
        @items[r.name][r.epics_stock_details_id] = {
         :item_code => nil , :min_stock => nil,:max_stock => nil, 
         :current_quantity => nil, :expiry_date => nil
        }
      end

      @items[r.name][r.epics_stock_details_id] = {
       :item_code => r.product_code, :min_stock => r.min_stock,
       :max_stock => r.max_stock, :current_quantity => r.current_quantity,
       :expiry_date => r.expiry_date, :batch_number => r.batch_number
      }
    end
  end

  def drug_availability_printable
    location = EpicsLocation.find(params[:store_room])
    @page_title = "#{location.name}<br />Drug availability"

    @items = EpicsStockDetails.joins("INNER JOIN epics_products p
      ON p.epics_products_id = epics_stock_details.epics_products_id
      LEFT JOIN epics_stock_expiry_dates x 
      ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id 
      ").where("epics_stock_details.epics_location_id = ?",location.id).select("p.* , 
      epics_stock_details.*, x.*").group('epics_stock_details.epics_stock_details_id').map do |r|
        {:item_code => r.product_code,:item_name => r.name, :min_stock => r.min_stock,
         :max_stock => r.max_stock, :current_quantity => r.current_quantity,
         :expiry_date => r.expiry_date 
        }
      end

    render :layout => false
  end
  
  def select_date_range
    render :layout => 'application'
  end

  def monthly_report
    @start_date = params[:date]['start'].to_date
    @monthly_report = EpicsReport.monthly_report(@start_date)
  end

  def monthly_report_printable
    @start_date = params[:start_date].to_date
    @monthly_report = EpicsReport.monthly_report(@start_date)
    render :layout => false
  end
  
  def daily_dispensation
    @page_title = "Daily dispensation<br />#{params[:date].to_date.strftime('%d, %B, %Y')}"
    @daily_dispensation = EpicsReport.daily_dispensation(params[:date].to_date)
  end

  def daily_dispensation_printable
    @page_title = "Daily dispensation<br />#{params[:date].to_date.strftime('%d, %B, %Y')}"
    @daily_dispensation = EpicsReport.daily_dispensation(params[:date].to_date)
    render :layout => false
  end
  
  def select_daily_dispensation_date
    render :layout => 'application'
  end

  def drug_daily_dispensation
    item_name = EpicsProduct.find(params[:id]).name
    @page_title = "#{item_name} Daily dispensation<br />#{params[:date].to_date.strftime('%d, %B, %Y')}"
    @daily_dispensation = EpicsReport.drug_daily_dispensation(params[:id], params[:date].to_date)
  end

  def expired_items
    @page_title = "Expired items"
    @items = EpicsReport.expired_items
  end

  def select_date_ranges
    render :layout => 'application'
  end

  def disposed_items
    start_date = params[:date]['start'].to_date
    end_date = params[:date]['end'].to_date
    @page_title = "Board Off Items<br />From #{start_date.strftime('%d %b, %Y')}
      to #{end_date.strftime('%d %b, %Y')}"
    @items = EpicsReport.disposed_items(start_date, end_date)
  end

  def print_drug_availability_report
      location = request.remote_ip rescue ""
      current_printer = ""
      store_room = params[:store_room]
      locations = EpicsGlobalProperty.find("facility.printers").property_value.split(",") rescue []
      locations.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/report/drug_availability_printable/" +\
            "?store_room=#{store_room}" + "\" /tmp/output-drug_availability_report" + ".pdf \n"
        }

        file = "/tmp/output-drug_availability_report" + ".pdf"
        t2 = Thread.new{
          sleep(3)
          print(file, current_printer)
        }
        render :text => "true" and return
  end

  def print_monthly_report
      location = request.remote_ip rescue ""
      current_printer = ""
      start_date = params[:start_date]
      locations = EpicsGlobalProperty.find("facility.printers").property_value.split(",") rescue []
      locations.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/report/monthly_report_printable/" +\
            "?start_date=#{start_date}" + "\" /tmp/output-monthly_report" + ".pdf \n"
        }

        file = "/tmp/output-monthly_report" + ".pdf"
        t2 = Thread.new{
          sleep(3)
          print(file, current_printer)
        }
        render :text => "true" and return
  end

  def print_store_room_report
      location = request.remote_ip rescue ""
      current_printer = ""
      store_room = params[:store_room]
      locations = EpicsGlobalProperty.find("facility.printers").property_value.split(",") rescue []
      locations.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/report/store_room_printable/" +\
            "?store_room=#{store_room}" + "\" /tmp/output-store_room_report" + ".pdf \n"
        }

        file = "/tmp/output-store_room_report" + ".pdf"
        t2 = Thread.new{
          sleep(3)
          print(file, current_printer)
        }
        render :text => "true" and return
  end

  def print_daily_dispensation_report
      location = request.remote_ip rescue ""
      current_printer = ""
      date = params[:date]
      locations = EpicsGlobalProperty.find("facility.printers").property_value.split(",") rescue []
      locations.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/report/daily_dispensation_printable/" +\
            "?date=#{date}" + "\" /tmp/output-daily_dispensation_report" + ".pdf \n"
        }

        file = "/tmp/output-daily_dispensation_report" + ".pdf"
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

  def disposed_items_printable
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    @page_title = "Board Off Items<br />From #{start_date.strftime('%d %b, %Y')}
      to #{end_date.strftime('%d %b, %Y')}"
    @items = EpicsReport.disposed_items(start_date, end_date)
    render :layout => false
  end
  
  def print_disposed_items_report
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    ##############################
      location = request.remote_ip rescue ""
      current_printer = ""
      date = params[:date]
      locations = EpicsGlobalProperty.find("facility.printers").property_value.split(",") rescue []
      locations.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/report/disposed_items_printable/" +\
            "?start_date=#{start_date}&end_date=#{end_date}" + "\" /tmp/output-disposed_items_report" + ".pdf \n"
        }

        file = "/tmp/output-disposed_items_report" + ".pdf"
        t2 = Thread.new{
          sleep(3)
          print(file, current_printer)
        }
        render :text => "true" and return
    ###############################
  end

  def expired_items_printable    
    @page_title = "Expired items"
    @items = EpicsReport.expired_items
    render :layout => false
  end
  
  def print_expired_items_report
      location = request.remote_ip rescue ""
      current_printer = ""
      locations = EpicsGlobalProperty.find("facility.printers").property_value.split(",") rescue []
      locations.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/report/expired_items_printable/" +\
             "\" /tmp/output-expired_items_report" + ".pdf \n"
        }

        file = "/tmp/output-expired_items_report" + ".pdf"
        t2 = Thread.new{
          sleep(3)
          print(file, current_printer)
        }
        render :text => "true" and return
    ###############################
  end

  def items_to_expire_next_six_months_attachment
    @alerts = EpicsStockExpiryDates.joins("
          INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
          INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id AND p.expire = 1
          ").where("DATEDIFF(expiry_date,CURRENT_DATE())
          BETWEEN 1 AND 183 AND current_quantity > 0").select("p.product_code code,p.name name,
          current_quantity quantity, min_stock, s.batch_number batch_number,
          max_stock, expiry_date").order("p.product_code,p.name,expiry_date")
    render :layout => false
  end

  def items_to_expire_next_six_months_to_pdf
    Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            "192.168.13.102:80" + "\"/report/items_to_expire_next_six_months_attachment/" +\
             "\" /tmp/items_to_expire_next_six_months" + ".pdf \n"
        }
  end

  def daily_dispensation_attachment
    today = Date.today
    @daily_dispensation = EpicsReport.daily_dispensation(today)
    render :layout => false
  end

  def daily_dispensation_to_pdf
    Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            "192.168.13.102:80" + "\"/report/daily_dispensation_attachment/" +\
             "\" /tmp/daily_dispensation" + ".pdf \n"
        }
  end

  def received_items_attachment
    start_date = Date.today#params[:date]['start'].to_date
    end_date = Date.today#params[:date]['end'].to_date
    @page_title = "Received/Issued:<br />" + start_date.strftime('%d %b, %Y')
    @page_title += " to " + end_date.strftime('%d %b, %Y')
    @received_items = EpicsReport.received_items(start_date,end_date)
    render :layout => false
  end

  def received_items_to_pdf
    Thread.new{
          Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
            "192.168.13.102:80" + "\"/report/received_items_attachment/" +\
             "\" /tmp/received_items" + ".pdf \n"
        }
  end
end
