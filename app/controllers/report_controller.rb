class ReportController < ApplicationController

  def audit_report
  end

  def received_items
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
        SUM(current_quantity) quantity, min_stock,
        max_stock,expiry_date").having("quantity > 0 AND quantity <= min_stock").order("p.product_code,p.name,MIN(expiry_date)")
      when 'Out of stock items'
        @alerts = EpicsStockDetails.joins("
          INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
          LEFT JOIN epics_stock_expiry_dates x ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id
        ").group('epics_stock_details.epics_stock_details_id').select("p.product_code code,p.name name, 
        SUM(current_quantity) quantity, min_stock,
        max_stock,expiry_date").having("quantity <= 0").order("p.product_code,p.name,MIN(expiry_date)")
      when 'Missing items'
      when 'Removed items'
      when 'Items expiring in the next 6 months'
        @alerts = EpicsStockExpiryDates.joins("
          INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
          INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id AND p.expire = 1
          ").where("DATEDIFF(expiry_date,CURRENT_DATE())
          BETWEEN 1 AND 183 AND current_quantity > 0").select("p.product_code code,p.name name, 
          current_quantity quantity, min_stock, max_stock, expiry_date").order("p.product_code,p.name,expiry_date")
    end
  end

  def select_store
    @report_name = params[:report]
    @report_name = 'store_room' if @report_name.blank?
    @store_rooms = EpicsLocation.all.map{|l| l.name }
    render :layout => 'application'
  end

  def store_room
    location_id = EpicsLocation.where("name = ?",params[:store_room])[0].id

    @epics_products = EpicsProduct.joins("INNER JOIN epics_stock_details s
      ON s.epics_products_id = epics_products.epics_products_id").where("s.epics_location_id = ?",
      location_id).select("epics_products.* , s.*").group("s.epics_products_id")
  end

  def drug_availability
    location_id = EpicsLocation.where("name = ?",params[:store_room])[0].id

    @epics_products = EpicsProduct.joins("INNER JOIN epics_stock_details s
      ON s.epics_products_id = epics_products.epics_products_id
      LEFT JOIN epics_stock_expiry_dates x 
      ON x.epics_stock_details_id = s.epics_stock_details_id 
      ").where("s.epics_location_id = ?",location_id).select("epics_products.* , s.*, x.*")
  end

  def select_date_range
    render :layout => 'application'
  end

  def monthly_report
    @start_date = params[:date]['start'].to_date
    @monthly_report = EpicsReport.monthly_report(@start_date)
  end
  
  def daily_dispensation
    @daily_dispensation = EpicsReport.daily_dispensation(params[:date].to_date)
  end

  def select_daily_dispensation_date
    render :layout => 'application'
  end

end
