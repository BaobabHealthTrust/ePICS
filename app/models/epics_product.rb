class EpicsProduct < ActiveRecord::Base
	set_table_name :epics_products
  set_primary_key :epics_products_id
  #default_scope where("voided = 0")
  default_scope where("#{table_name}.voided = 0")
  belongs_to :epics_product_units, :foreign_key => :epics_product_units_id
  belongs_to :epics_product_type, :foreign_key => :epics_product_type_id
  belongs_to :epics_product_category, :foreign_key => :epics_product_category_id
  has_many :epics_stock_details,:class_name => 'EpicsStockDetails', 
    :foreign_key => :epics_products_id, :conditions => {:voided => 0}


  def current_quantity(end_date = Date.today)
    EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id").where("
      s.grn_date <= ?", end_date).sum(:current_quantity)
  end

  def received_quantity(end_date = Date.today)
    EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id").where("
      s.grn_date <= ?", end_date).sum(:received_quantity)
  end

  def losses_quantity(end_date = Date.today)

    EpicsStockDetails.find_by_sql("SELECT SUM(current_quantity) count FROM
      epics_stock_details INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id
      WHERE s.grn_date <= '#{end_date}' AND epics_stock_details.voided = 1 
      AND epics_stock_details.void_reason IN('damaged','missing','expired')").first.count.to_i rescue 0
  end

  def positive_adjustments(end_date = Date.today)
    type = EpicsLendsOrBorrowsType.where("name = ?",'Borrow')[0]

    borrowed = EpicsLendsOrBorrows.joins("INNER JOIN epics_stocks es
    ON es.epics_stock_id = epics_lends_or_borrows.epics_stock_id
    AND epics_lends_or_borrows.epics_lends_or_borrows_type_id = #{type.id}
    INNER JOIN epics_stock_details s ON s.epics_stock_id = es.epics_stock_id
    AND s.epics_products_id = #{self.id}").where("es.grn_date <= ?", end_date).sum(:received_quantity)


    exchange = EpicsExchange.joins("INNER JOIN epics_product_orders o 
      ON o.epics_order_id=epics_exchanges.epics_order_id
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND s.epics_products_id = #{self.id} INNER JOIN epics_stocks e              
      ON e.epics_stock_id = s.epics_stock_id").where("e.grn_date <= ?",
      end_date).sum(:received_quantity)
       
    count = [exchange.to_f , borrowed.to_f].sum
    if(count.to_s.split('.')[1] == '0')
      return count.to_i
    end
    return count
  end

  def negative_adjustments(end_date = Date.today)
    type_ids = EpicsOrderTypes.where("name IN(?)",['Lend','Exchange']).map(&:id)

    epics_lends = EpicsOrders.joins("INNER JOIN epics_product_orders o
      ON o.epics_order_id = epics_orders.epics_order_id
      AND epics_orders.epics_order_type_id IN(#{type_ids.join(',')})
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND s.epics_products_id=#{self.id} INNER JOIN epics_stocks e 
      ON e.epics_stock_id = s.epics_stock_id").where("e.grn_date <= ?" ,end_date).sum(:quantity)
    
    return epics_lends
  end

  def issued(end_date = Date.today)
    type = EpicsOrderTypes.where("name = ?",'Dispense')[0]

    issued = EpicsOrders.joins("INNER JOIN epics_product_orders o
      ON o.epics_order_id = epics_orders.epics_order_id
      AND epics_orders.epics_order_type_id IN(#{type.id})
      INNER JOIN epics_stock_details s ON s.epics_stock_details_id = o.epics_stock_details_id
      AND s.epics_products_id=#{self.id} INNER JOIN epics_stocks e 
      ON e.epics_stock_id = s.epics_stock_id").where("e.grn_date <= ?", end_date).sum(:quantity)
   
    return 0 if issued == '0' 
    return issued
  end

  def days_stocked_out(end_date = Date.today)
    stocked_out = EpicsStockDetails.joins("INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id").where("epics_products_id = ? 
      AND s.grn_date <=?", self.id, end_date).select("epics_stock_details.updated_at last_update, 
      SUM(current_quantity) curr_quantity").having("curr_quantity <= 0").order("last_update DESC").map(&:last_update)

    unless stocked_out.blank?
      days = EpicsStockDetails.select("DATEDIFF(DATE('#{end_date}'),DATE('#{stocked_out.last.to_date}')) AS days_gone")[0]
      return days[:days_gone].to_i
    else
      return 'N/A'
    end
  end

end
