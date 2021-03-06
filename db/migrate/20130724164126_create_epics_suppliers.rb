class CreateEpicsSuppliers < ActiveRecord::Migration
  def self.up
   create_table :epics_suppliers, :primary_key => :epics_supplier_id do |t|
			t.string :name
			t.boolean :local
			t.string :address
			t.string :phone_number
			t.integer :epics_supplier_type_id
			t.string :description
			t.boolean :voided, :default => false
			t.timestamps
		end
  end

  def self.down
    drop_table :epics_suppliers
  end
end
