class EpicsStock < ActiveRecord::Base
	set_table_name :epics_stocks
  set_primary_key :epics_stock_id
  default_scope where('voided = 0')
  has_many :epics_stock_details
  has_many :epics_witness_names
  belongs_to :epics_supplier, :foreign_key => :epics_supplier_id
end
