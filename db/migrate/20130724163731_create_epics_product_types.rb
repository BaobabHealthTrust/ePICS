class CreateEpicsProductTypes < ActiveRecord::Migration
  def self.up
    create_table :epics_product_types, :primary_key => :epics_product_type_id do |t|
			t.string :name
			t.string :description
			t.boolean :voided, :default => false
			t.timestamps
		end
  end

  def self.down
    drop_table :epics_product_types
  end
end
