class EpicsReport < ActiveRecord::Base


  def self.alerts
    alerts = Hash.new(0)                                                       
                                                                                
    alerts['Items expiring in the next 6 months'] += EpicsStockExpiryDates.joins("
      INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
      INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id  
      AND p.expire = 1").where("DATEDIFF(expiry_date,CURRENT_DATE())            
      BETWEEN 1 AND 183 AND current_quantity > 0").count(:expiry_date)                                   
                                                                                
    alerts['Items below minimum stock'] += EpicsStockDetails.joins("           
      INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
    ").group('epics_stock_details.epics_products_id').select("SUM(current_quantity) quantity,
      min_stock").having("quantity > 0 AND quantity <= min_stock").length                        
                                                                                
    alerts['Out of stock items'] += EpicsStockDetails.joins("                  
      INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
    ").group('epics_stock_details.epics_stock_details_id').select("SUM(current_quantity) quantity,
      min_stock").having("quantity <= 0").length                                
                                                                                
    alerts['Missing items']+= 0                                                
    alerts['Removed items']+= 0 
    return alerts
  end

  def self.monthly_report(end_date)
    @item_categories = {}
    EpicsProductCategory.all.each do |cat|
      (self.get_receipts_by_category_and_date(cat.id,end_date) || []).each do |receipt|
        if @item_categories[receipt[:grn_date]].blank?
          @item_categories[receipt[:grn_date]] = {}
        end
        
        if @item_categories[receipt[:grn_date]]["#{cat.name}: #{cat.description}"].blank?  
          @item_categories[receipt[:grn_date]]["#{cat.name}: #{cat.description}"] = {} 
        end
      
        if @item_categories[receipt[:grn_date]]["#{cat.name}: #{cat.description}"][receipt[:item_id]].blank?
          item = EpicsProduct.find(receipt[:item_id])
          @item_categories[receipt[:grn_date]]["#{cat.name}: #{cat.description}"][receipt[:item_id]] = {
            :item_code => receipt[:item_code],
            :item => receipt[:item_name],
            :unit_of_issue => receipt[:unit_of_issue],
            :current_quantity => item.current_quantity(end_date.to_date),
            :received_quantity => item.received_quantity(end_date.to_date),
            :losses => item.losses_quantity(end_date.to_date),
            :positive_adjustments => item.positive_adjustments(end_date.to_date),
            :negative_adjustments => item.negative_adjustments(end_date.to_date),
            :issued => item.issued(end_date.to_date),
            :days_stocked_out => item.days_stocked_out(end_date.to_date)
          }
        end 

      end
    end

    return @item_categories
  end

  def self.get_receipts_by_category_and_date(category_id, end_date)
    EpicsStock.joins("
      INNER JOIN epics_stock_details s ON epics_stocks.epics_stock_id = s.epics_stock_id 
      AND epics_stocks.grn_date <= '#{end_date}'
      INNER JOIN epics_products e ON s.epics_products_id = e.epics_products_id
      INNER JOIN epics_product_units u ON u.epics_product_units_id = e.epics_product_units_id
      AND e.epics_product_category_id = #{category_id}
    ").group("e.epics_products_id").select("
      epics_stocks.grn_date, e.epics_products_id , product_code, e.name product_name, u.name unit
    ").collect do |r| {
      :grn_date => r.grn_date, :item_id => r.epics_products_id.to_i , 
      :item_code => r.product_code, :item_name => r.product_name, 
      :unit_of_issue => r.unit } 
    end
  end

  def self.daily_dispensation(date = Date.today)
    type = EpicsOrderTypes.where("name = ?",'Dispense')[0]
    start_date = date.strftime('%Y-%m-%d 00:00:00')
    end_date = date.strftime('%Y-%m-%d 23:59:59')

    issued = EpicsOrders.joins("INNER JOIN epics_product_orders o
      ON o.epics_order_id = epics_orders.epics_order_id
      AND epics_orders.epics_order_type_id IN(#{type.id})
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND s.created_at >= '#{start_date}' AND s.created_at <= '#{end_date}'
      INNER JOIN epics_locations l ON l.epics_location_id = s.epics_location_id
      INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id
      ").select("p.name pname,l.name lname,s.created_at dispensed_date,SUM(quantity) quantity,
        p.product_code item_code").group("s.epics_products_id,l.epics_location_id")
    
    return issued.collect do |r|{
      :item_name => r.pname, :issued_to => r.lname,:item_code => r.item_code,
      :issue_date => r.dispensed_date, :quantity_issued => r.quantity
      }
    end
  end

end
