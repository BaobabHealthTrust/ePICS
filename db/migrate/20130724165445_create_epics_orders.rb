class CreateEpicsOrders < ActiveRecord::Migration
  def self.up
    create_table :epics_orders, :primary_key => :epics_order_id do |t|
			t.integer :epics_order_type_id
			t.integer :epics_location_id
			t.text :instructions
			t.boolean :voided, :default => false
      t.integer :creator
			t.timestamps
		end
  end

  def self.down
    drop_table :epics_orders
  end
end
