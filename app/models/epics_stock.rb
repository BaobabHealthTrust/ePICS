class EpicsStock < ActiveRecord::Base
	set_table_name :epics_stocks
  set_primary_key :epics_stock_id
  default_scope where('voided = 0')
  has_many :epics_stock_details, :foreign_key => :epics_stock_id, :conditions => {:voided => 0}
end
