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

end
