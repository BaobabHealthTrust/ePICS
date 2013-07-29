class EpicsProductCategory < ActiveRecord::Base
  set_table_name :epics_product_category
	set_primary_key :epics_product_order_id
  default_scope where('voided = 0')
  belongs_to :epics_orders, :foreign_key => :epics_order_id, :conditions => {:voided => 0}
  belongs_to :epics_stock_details, :foreign_key => :epics_stock_details_id, :conditions => {:voided => 0}
end
