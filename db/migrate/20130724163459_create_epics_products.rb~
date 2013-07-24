class CreateEpicsProducts < ActiveRecord::Migration
  def self.up
    create_table :epics_products, :primary_key => :epics_products_id do |t|
      t.string :name
      t.string :product_code
      t.boolean :expire
      t.decimal :min_stock
      t.decimal :max_stock
      t.integer :epics_product_units_id
      t.integer :epics_product_type_id
      t.integer :creator
      t.boolean :voided, :default => false
      t.string :void_reason
      t.datetime :date_voided

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_products
  end
end
