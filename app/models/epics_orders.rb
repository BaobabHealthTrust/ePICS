class EpicsOrders < ActiveRecord::Base
	set_table_name :epics_orders 
	set_primary_key :epics_order_id
  default_scope where('voided = 0')
  belongs_to :epics_order_types, :foreign_key => :epics_order_type_id, :conditions => {:voided => 0}
  has_many :epics_product_orders, :foreign_key => :epics_order_id, :conditions => {:voided => 0}
end
