class EpicsProduct < ActiveRecord::Base
	set_table_name :epics_products
  set_primary_key :epics_products_id
  default_scope where('voided = 0')
  belongs_to :epics_product_units, :foreign_key => :epics_product_units_id
  belongs_to :epics_product_types, :foreign_key => :epics_product_type_id
end
