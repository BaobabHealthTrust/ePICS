class CreateEpicsLendsOrBorrows < ActiveRecord::Migration
  def self.up
    create_table :epics_lends_or_borrows, :primary_key => :epics_lends_or_borrows_id do |t|
			t.integer :epics_orders_id
			t.integer :epics_stock_id
			t.integer :epics_lends_or_borrows_type_id
			t.date :lend_or_borrow_date
			t.date :return_date
			t.boolean :reimbursed, :default => false
			t.boolean :voided, :default => false
			t.timestamps
		end
  end

  def self.down
    drop_table :epics_lends_or_borrows
  end
end
