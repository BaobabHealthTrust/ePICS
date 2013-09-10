class CreateEpicsStockDetails < ActiveRecord::Migration
  def self.up
    create_table :epics_stock_details, :primary_key => :epics_stock_details_id do |t|
			t.integer :epics_stock_id
			t.integer :epics_products_id
			t.integer :received_quantity
      t.integer :current_quantity
			t.integer :epics_product_units_id
			t.integer :epics_location_id
			t.boolean :voided, :default => false
			t.string :void_reason
      t.integer :voided_by
			t.timestamps
		end
  end

  def self.down
    drop_table :epics_stock_details
  end
end
