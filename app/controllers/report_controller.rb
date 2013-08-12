class ReportController < ApplicationController

  def drug_availability
    
  end
  def audit_report
    
  end
  def daily_dispensation
    
  end
  def store_room

  end
  def received_items

  end
  def monthly_report
    
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
        ").group('epics_stock_details.epics_stock_details_id').select("p.product_code code,p.name name, 
        SUM(current_quantity) quantity, min_stock,
        max_stock,expiry_date").having("quantity <= min_stock").order("p.product_code,p.name")
      when 'Out of stock items'
        @alerts = EpicsStockDetails.joins("
          INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
          LEFT JOIN epics_stock_expiry_dates x ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id
        ").group('epics_stock_details.epics_stock_details_id').select("p.product_code code,p.name name, 
        SUM(current_quantity) quantity, min_stock,
        max_stock,expiry_date").having("quantity <= 0").order("p.product_code,p.name")
      when 'Missing items'
      when 'Removed items'
      when 'Items expiring in the next 6 months'
        @alerts = EpicsStockExpiryDates.joins("
          INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
          INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id AND p.expire = 1
          ").where("DATEDIFF(expiry_date,CURRENT_DATE())
          BETWEEN 1 AND 183").select("p.product_code code,p.name name, 
          current_quantity quantity, min_stock, max_stock, expiry_date").order("p.product_code,p.name")
    end
  end

end
