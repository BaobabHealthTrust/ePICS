class CreateEpicsItemCosts < ActiveRecord::Migration
  def self.up
    create_table :epics_item_costs, :primary_key => :epics_item_cost_id do |t|
      t.integer :epics_products_id
      t.float :unit_price
      t.float :pack_size
      t.float :billing_charge
      t.integer :creator
      t.boolean :voided, :default => false
      t.string :void_reason
      t.datetime :date_voided

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_item_costs
  end
end
