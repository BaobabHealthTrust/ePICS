class CreateEpicsStocks < ActiveRecord::Migration
  def self.up
    create_table :epics_stocks, :primary_key => :epics_stock_id do |t|
			t.string :grn_number
			t.integer :epics_supplier_id
			t.date :grn_date
			t.boolean :voided, :default => false
			t.timestamps
      t.integer :creator
		end
  end

  def self.down
    drop_table :epics_stocks
  end
end
