class CreateEpicsLendBorrowAuthorizers < ActiveRecord::Migration
  def self.up
    create_table :epics_lend_borrow_authorizers, :primary_key => :authorization_id do |t|

      t.integer :authorizer
      t.integer :epics_lends_or_borrows_id
      t.boolean :authorized, :default => false
      t.boolean :voided, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :epics_lend_borrow_authorizers
  end
end
