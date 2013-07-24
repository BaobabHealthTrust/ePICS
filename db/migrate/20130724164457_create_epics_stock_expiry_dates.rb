class CreateEpicsStockExpiryDates < ActiveRecord::Migration
  def self.up
    create_table :epics_stock_expiry_dates, :primary_key => :epics_stock_expiry_date_id do |t|
			t.integer :epics_stock_details_id
			t.date :expiry_date
			t.boolean :voided, :default => false
			t.timestamps
		end
  end

  def self.down
    drop_table :epics_stock_expiry_dates
  end
end
