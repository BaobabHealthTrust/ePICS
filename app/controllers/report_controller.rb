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
    @expiring_products = EpicsStockExpiryDates.joins("
      INNER JOIN epics_stock_details s ON s.epics_stock_id = epicsStock_expiry_dates.epics_stock_details_id
      INNER JOIN epics_products p 
      ON p.epics_products_id = s.epics_products_id").where("")  
  end

end
