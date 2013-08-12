class EpicsReport < ActiveRecord::Base


  def self.alerts
    alerts = Hash.new(0)                                                       
                                                                                
    alerts['Items expiring in the next 6 months'] += EpicsStockExpiryDates.joins("
      INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
      INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id  
      AND p.expire = 1").where("DATEDIFF(expiry_date,CURRENT_DATE())            
      BETWEEN 1 AND 183").count(:expiry_date)                                   
                                                                                
    alerts['Items below minimum stock'] += EpicsStockDetails.joins("           
      INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
    ").group('epics_stock_details.epics_stock_details_id').select("SUM(current_quantity) quantity,
      min_stock").having("quantity <= min_stock").length                        
                                                                                
    alerts['Out of stock items'] += EpicsStockDetails.joins("                  
      INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
    ").group('epics_stock_details.epics_stock_details_id').select("SUM(current_quantity) quantity,
      min_stock").having("quantity <= 0").length                                
                                                                                
    alerts['Missing items']+= 0                                                
    alerts['Removed items']+= 0 
    return alerts
  end

end
