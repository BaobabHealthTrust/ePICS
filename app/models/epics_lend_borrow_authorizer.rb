class EpicsLendBorrowAuthorizer < ActiveRecord::Base
  set_table_name :epics_lend_borrow_authorizers
  set_primary_key :authorizer_id
  default_scope where('voided = 0')
  belongs_to :epics_lends_or_borrows, :foreign_key => :epics_lends_or_borrows_id, :conditions => {:voided => 0}
  belongs_to :epics_person, :foreign_key => :epics_person_id, :conditions => {:voided => 0}

end
