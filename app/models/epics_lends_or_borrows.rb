class EpicsLendsOrBorrows < ActiveRecord::Base
	set_table_name :epics_lends_or_borrows
	set_primary_key :epics_lends_or_borrows_id
  default_scope where('voided = 0')
end
