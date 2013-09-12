class EpicsContact < ActiveRecord::Base
  set_table_name :epics_contacts
  set_primary_key :epics_contact_id
  default_scope where("#{table_name}.voided = 0")
end
