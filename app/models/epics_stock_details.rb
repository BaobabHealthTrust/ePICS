class EpicsStockDetails < ActiveRecord::Base
	set_table_name :epics_stock_details
 	set_primary_key :epics_stock_details_id
  default_scope where('voided = 0')
  belongs_to :epics_stock
  belongs_to :epics_product, :foreign_key => :epics_products_id, :conditions => {:voided => 0}
  belongs_to :epics_location, :foreign_key => :epics_location_id, :conditions => {:voided => 0}
  has_one :epics_stock_expiry_dates, :foreign_key => :epics_stock_details_id, :conditions => {:voided => 0}
end
