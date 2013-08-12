class CreateEpicsLendBorrowAuthorizers < ActiveRecord::Migration
  def self.up
    create_table :epics_lend_borrow_authorizers, :primary_key => :authorizer_id do |t|

      t.integer :epics_person_id
      t.integer :epics_lends_or_borrows_id
      t.boolean :voided, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :epics_lend_borrow_authorizers
  end
end
