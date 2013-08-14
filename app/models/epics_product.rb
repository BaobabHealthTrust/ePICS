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


  def current_quantity(start_date = Date.today, end_date = Date.today)
    EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id").where("
      s.grn_date >= ? AND s.grn_date <= ?",start_date,end_date).sum(:current_quantity)
  end

  def received_quantity(start_date = Date.today, end_date = Date.today)
    EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id").where("
      s.grn_date >= ? AND s.grn_date <= ?",start_date,end_date).sum(:received_quantity)
  end

  def losses_quantity(start_date = Date.today, end_date = Date.today)

    EpicsStockDetails.find_by_sql("SELECT SUM(current_quantity) count FROM
      epics_stock_details INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id
      WHERE s.grn_date >= '#{start_date}' AND s.grn_date <= '#{end_date}' 
      AND epics_stock_details.voided = 1 
      AND epics_stock_details.void_reason IN('damaged','missing','expired')").first.count.to_i rescue 0
  end

  def positive_adjustments(start_date = Date.today, end_date = Date.today)
    epics_exchanges_positive = EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id
      INNER JOIN epics_exchanges x ON x.epics_stock_id = s.epics_stock_id
      INNER JOIN epics_product_orders po 
      ON po.epics_stock_details_id = epics_stock_details.epics_stock_details_id").where("
      s.grn_date >= ? AND s.grn_date <= ?",start_date,end_date).sum(:quantity.to_s)

    type = EpicsLendsOrBorrowsType.where("name = ?",'Borrow')[0]

    epics_borrows = EpicsStockDetails.joins("INNER JOIN epics_products p 
      ON epics_stock_details.epics_products_id = p.epics_products_id 
      AND p.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s 
      ON s.epics_stock_id = epics_stock_details.epics_stock_id
      INNER JOIN epics_lends_or_borrows b ON b.epics_stock_id = s.epics_stock_id
      AND b.epics_lends_or_borrows_type_id=#{type.id}
      INNER JOIN epics_product_orders po                                        
      ON po.epics_stock_details_id = epics_stock_details.epics_stock_details_id").where("
      s.grn_date >= ? AND s.grn_date <= ?",start_date,end_date).sum(:quantity.to_s)

    return [epics_borrows.to_f , epics_exchanges_positive.to_f].sum
  end

  def negative_adjustments(start_date = Date.today, end_date = Date.today)
    type = EpicsLendsOrBorrowsType.where("name = ?",'Lend')[0]

    epics_lends = EpicsLendsOrBorrows.joins("INNER JOIN epics_orders o
    ON o.epics_order_id = epics_lends_or_borrows.epics_orders_id
    INNER JOIN epics_product_orders po ON po.epics_order_id = o.epics_order_id
    INNER JOIN epics_stock_details s ON s.epics_stock_id = po.epics_stock_details_id 
    AND s.epics_products_id = #{self.id} 
    INNER JOIN epics_stocks ON epics_stocks.epics_stock_id = s.epics_stock_id
    ").where("epics_stocks.grn_date >= ? AND epics_stocks.grn_date <= ?
    AND epics_lends_or_borrows.epics_lends_or_borrows_type_id = ?",
    start_date,end_date,type.id).sum(:quantity)
    
    epics_exchanges_negatives = EpicsExchange.joins("INNER JOIN epics_orders o
      ON o.epics_order_id = epics_exchanges.epics_order_id
      INNER JOIN epics_product_orders po ON po.epics_order_id = o.epics_order_id
      INNER JOIN epics_stock_details d ON d.epics_stock_details_id = po.epics_stock_details_id
      AND d.epics_products_id = #{self.id}
      INNER JOIN epics_stocks s ON s.epics_stock_id = d.epics_stock_id").where(" 
      s.grn_date >= ? AND s.grn_date <= ?",start_date,end_date).sum(:quantity)

    return [epics_exchanges_negatives.to_f , epics_lends.to_f].sum
  end

  def issued(start_date = Date.today, end_date = Date.today)
  end

end
