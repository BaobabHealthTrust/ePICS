class CreateEpicsProductOrders < ActiveRecord::Migration
  def self.up
    create_table :epics_product_orders, :primary_key => :epics_product_order_id do |t|
			t.integer :epics_order_id
			t.integer :epics_stock_details_id
			t.decimal :quantity
			t.boolean :voided, :default => false
			t.timestamps
		end
  end

  def self.down
    drop_table :epics_product_orders
  end
end
