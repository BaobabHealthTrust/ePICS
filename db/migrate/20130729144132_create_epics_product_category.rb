class CreateEpicsProductCategory < ActiveRecord::Migration
  def self.up
    create_table :epics_product_category, :primary_key => :epics_product_category_id do |t|
      t.string :class
      t.string :name
      t.string :description
      t.boolean :voided, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :epics_product_category
  end
end
