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
      min_stock").having("quantity > 0 AND quantity < min_stock").length                        
                                                                                
    alerts['Out of stock items'] += EpicsStockDetails.joins("                  
      INNER JOIN epics_products p ON p.epics_products_id = epics_stock_details.epics_products_id
    ").group('epics_stock_details.epics_stock_details_id').select("SUM(current_quantity) quantity,
      min_stock").having("quantity <= 0").length                                
                                                                                
    sql=<<EOF
      SELECT count(s.epics_products_id) num_of_items FROM epics_stocks stock 
      INNER JOIN epics_stock_details s ON s.epics_stock_id = stock.epics_stock_id
      AND s.voided = 1 AND s.void_reason LIKE '%missing%'
EOF

    alerts['Missing items'] += EpicsStock.find_by_sql(sql).map { |r| 
      r.num_of_items 
    }[0].to_i rescue 0



    alerts['Expired items'] += EpicsStockExpiryDates.joins("
      INNER JOIN epics_stock_details s ON s.epics_stock_id = epics_stock_expiry_dates.epics_stock_details_id
      INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id  
      AND p.expire = 1").where("DATEDIFF(expiry_date,CURRENT_DATE()) <= 0         
      AND current_quantity > 0").count(:expiry_date)                                   

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
      AND o.created_at >= '#{start_date}' AND o.created_at <= '#{end_date}'
      INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id
      ").select("p.name pname,s.created_at dispensed_date,SUM(quantity) quantity,
        p.product_code item_code,s.epics_products_id item_id").group("s.epics_products_id")
    
    return issued.collect do |r|{
      :item_name => r.pname, :item_id => r.item_id,
      :item_code => r.item_code,:issue_date => r.dispensed_date, 
      :quantity_issued => r.quantity
      }
    end
  end

  def self.drug_daily_dispensation(item_id, date = Date.today)
    type = EpicsOrderTypes.where("name = ?",'Dispense')[0]
    start_date = date.strftime('%Y-%m-%d 00:00:00')
    end_date = date.strftime('%Y-%m-%d 23:59:59')

    issued = EpicsOrders.joins("INNER JOIN epics_product_orders o
      ON o.epics_order_id = epics_orders.epics_order_id
      AND epics_orders.epics_order_type_id IN(#{type.id})
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND o.created_at >= '#{start_date}' AND o.created_at <= '#{end_date}'
      AND s.epics_products_id = #{item_id}
      INNER JOIN epics_locations l ON l.epics_location_id = s.epics_location_id
      INNER JOIN epics_locations i ON i.epics_location_id = epics_orders.epics_location_id
      INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id
      ").select("p.name pname,l.name lname,s.created_at dispensed_date,SUM(quantity) quantity,
        p.product_code item_code,i.name issued_to,s.epics_products_id item_id").group("s.epics_products_id,i.epics_location_id")
    
    return issued.collect do |r|{
      :item_name => r.pname, :issued_from => r.lname,:item_id => r.item_id,
      :item_code => r.item_code,:issue_date => r.dispensed_date, 
      :quantity_issued => r.quantity, :issued_to => r.issued_to
      }
    end
  end

  ############################### stock card ##############################################
   def self.current_quantity(stock, item, end_date = Date.today)
    EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{item.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id").where("
      s.grn_date <= ? AND s.epics_stock_id = ?", end_date,stock.id).sum(:current_quantity)
  end

  def self.received_quantity(stock, item, end_date = Date.today)
    EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{item.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id").where("
      s.grn_date <= ? AND s.epics_stock_id = ?", end_date,stock.id).sum(:received_quantity)
  end

  def self.losses_quantity(stock, item, end_date = Date.today)

    EpicsStockDetails.find_by_sql("SELECT SUM(current_quantity) count FROM
      epics_stock_details INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{item.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id
      WHERE s.grn_date <= '#{end_date}' AND epics_stock_details.voided = 1 
      AND epics_stock_details.void_reason IN('damaged','missing','expired')
      AND s.epics_stock_id = #{stock.id}").first.count.to_i rescue 0
  end

  def self.positive_adjustments(stock, item, end_date = Date.today)
    type = EpicsLendsOrBorrowsType.where("name = ?",'Borrow')[0]

    borrowed = EpicsLendsOrBorrows.joins("INNER JOIN epics_stocks es
    ON es.epics_stock_id = epics_lends_or_borrows.epics_stock_id
    AND epics_lends_or_borrows.epics_lends_or_borrows_type_id = #{type.id}
    INNER JOIN epics_stock_details s ON s.epics_stock_id = es.epics_stock_id
    AND s.epics_products_id = #{item.id}").where("es.grn_date <= ?
    AND es.epics_stock_id = ?", end_date, stock.id).sum(:received_quantity)


    exchange = EpicsExchange.joins("INNER JOIN epics_product_orders o 
      ON o.epics_order_id=epics_exchanges.epics_order_id
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND s.epics_products_id = #{item.id} INNER JOIN epics_stocks e              
      ON e.epics_stock_id = s.epics_stock_id").where("e.grn_date <= ?
      AND e.epics_stock_id = ?",end_date,stock.id).sum(:received_quantity)
      
    receipts = EpicsStock.joins("INNER JOIN epics_stock_details s               
      ON s.epics_stock_id = epics_stocks.epics_stock_id                         
      AND s.epics_products_id = #{item.id}").where("epics_stocks.grn_date <= ?
      AND epics_stocks.epics_stock_id = ?",end_date,stock.id).sum(:received_quantity)                                         
                                                                                
    count = [exchange.to_f , borrowed.to_f].sum
    count = [count , (receipts.to_f - count)].sum
 
    if(count.to_s.split('.')[1] == '0')
      return count.to_i
    end
    return count
  end

  def self.negative_adjustments(stock, item, end_date = Date.today)
    type_ids = EpicsOrderTypes.where("name IN(?)",['Lend','Exchange','Return']).map(&:id)

    epics_lends = EpicsOrders.joins("INNER JOIN epics_product_orders o
      ON o.epics_order_id = epics_orders.epics_order_id
      AND epics_orders.epics_order_type_id IN(#{type_ids.join(',')})
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND s.epics_products_id=#{item.id} INNER JOIN epics_stocks e 
      ON e.epics_stock_id = s.epics_stock_id").where("e.grn_date <= ?
      AND e.epics_stock_id = ?" ,end_date,stock.id).sum(:quantity)
    
    return epics_lends
  end

  def self.issued(stock, item, end_date = Date.today)
    type = EpicsOrderTypes.where("name = ?",'Dispense')[0]

    issued = EpicsOrders.joins("INNER JOIN epics_product_orders o
      ON o.epics_order_id = epics_orders.epics_order_id
      AND epics_orders.epics_order_type_id IN(#{type.id})
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND s.epics_products_id=#{item.id} INNER JOIN epics_stocks e 
      ON e.epics_stock_id = s.epics_stock_id").where("e.grn_date <= ?
      AND e.epics_stock_id = ?", end_date, stock.id).sum(:quantity)
   
    return 0 if issued == '0' 
    return issued
  end

  def self.current_quantity(stock,item)
    EpicsStockDetails.where("epics_stock_id = ? AND epics_products_id = ?",
      stock.id,item.id).first.current_quantity 
  end
  ############################### stock card ends #########################################	

  def self.expired_items
    EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON p.epics_products_id = epics_stock_details.epics_products_id
      INNER JOIN epics_stock_expiry_dates x 
      ON x.epics_stock_details_id = epics_stock_details.epics_stock_details_id
      ").where("x.expiry_date <= CURRENT_DATE()").select("p.product_code item_code,p.name,
      x.expiry_date,epics_stock_details.current_quantity,
      p.epics_products_id item_id,epics_stock_details.epics_stock_details_id").map do |r|
        {:item_code => r.item_code,:item_name => r.name,:item_id => r.item_id,
         :current_quantity => r.current_quantity, :expiry_date => r.expiry_date,
         :stock_details_id => r.epics_stock_details_id
        }
      end
  end

  def self.disposed_items(start_date, end_date)
    start_date = start_date.strftime('%Y-%m-%d 00:00:00')
    end_date = end_date.strftime('%Y-%m-%d 23:59:59')

    EpicsStockDetails.find_by_sql("
     SELECT p.product_code item_code,p.name,
     x.expiry_date,s.current_quantity,
     p.epics_products_id item_id, s.epics_stock_details_id, 
     s.updated_at date_removed, s.void_reason,s.received_quantity
     FROM epics_stock_details s INNER JOIN epics_products p 
     ON p.epics_products_id = s.epics_products_id
     INNER JOIN epics_stock_expiry_dates x 
     ON x.epics_stock_details_id = s.epics_stock_details_id 
     WHERE (s.voided = 1) AND (s.updated_at >= '#{start_date}' 
     AND s.updated_at <= '#{end_date}')").map do |r|
        {:item_code => r.item_code,:item_name => r.name,:item_id => r.item_id,
         :current_quantity => r.current_quantity, :expiry_date => r.expiry_date,
         :stock_details_id => r.epics_stock_details_id,:voided_at => r.date_removed,
         :void_reason => r.void_reason,:received_quantity => r.received_quantity
        }
      end
  end

  def self.audit(start_date, end_date)
    start_date = start_date.strftime('%Y-%m-%d 00:00:00')
    end_date = end_date.strftime('%Y-%m-%d 23:59:59')

    sql=<<EOF
      SELECT c.pack_size,c.billing_charge,
      p.product_code item_code,p.name, c.unit_price, p.epics_products_id item_id,
      sum(s.received_quantity) received,sum(o.quantity) issued, s.received_quantity 
      FROM epics_stocks e INNER JOIN epics_stock_details s ON s.epics_stock_id = e.epics_stock_id
      AND e.created_at >= '#{start_date}' AND e.created_at <= '#{end_date}' 
      AND s.voided = 0 AND e.voided = 0
      LEFT JOIN epics_product_orders o ON o.epics_stock_details_id = s.epics_stock_details_id
      AND o.created_at >= '#{start_date}' AND o.created_at <= '#{end_date}' AND o.voided = 0
      INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id
      LEFT JOIN epics_item_costs c ON p.epics_products_id = c.epics_products_id
      GROUP BY s.epics_products_id 
EOF

    EpicsStockDetails.find_by_sql(sql).map do |r|
        balance = r.received_quantity
        value_spent = 'N/A'
        amount_in_hand = 'N/A'

        if r.issued
          balance = (r.received_quantity.to_f - r.issued.to_f)
          balance = balance.to_i if (balance.to_s[-2..-1] =='.0')
        else
          r.issued = 0
        end
        
        if not r.unit_price.blank? and not r.pack_size.blank?
          item_value = (r.received_quantity.to_f/r.pack_size.to_f)* r.unit_price.to_f
          value_spent = (r.issued.to_f/r.pack_size.to_f)* r.unit_price.to_f
          amount_in_hand = (item_value - value_spent)
        end

        {:item_code => r.item_code,:item_name => r.name,:item_id => r.item_id,
         :received_quantity => r.received_quantity, :issued => r.issued,
         :billing_charge => r.billing_charge,:unit_price => r.unit_price, 
         :balance => balance,:pack_size => r.pack_size,
         :value_spent => value_spent, :amount_in_hand => amount_in_hand
        }
      end
  end

  def self.received_items(start_date, end_date)

    sql=<<EOF
    SELECT p.product_code item_code,p.name item_name,
      sum(s.received_quantity) as received, sum(s.received_quantity - s.current_quantity) as issued
      FROM epics_stock_details s INNER JOIN epics_products p ON p.epics_products_id = s.epics_products_id
      INNER JOIN epics_stocks e ON e.epics_stock_id = s.epics_stock_id AND s.voided = 0
      WHERE e.grn_date BETWEEN '#{start_date}' AND '#{end_date}' group by p.epics_products_id
EOF

    EpicsStockDetails.find_by_sql(sql).map do |r|
        {:item_code => r.item_code,:item_name => r.item_name,
         :received => r.received, :issued => r.issued
        }
    end

  end

end
