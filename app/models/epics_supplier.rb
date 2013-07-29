class EpicsSupplier < ActiveRecord::Base
	set_table_name :epics_suppliers
	set_primary_key :epics_supplier_id
  default_scope where('voided = 0')
  belongs_to :epics_supplier_type, :foreign_key => :epics_supplier_type_id, :conditions => {:voided => 0}
end
