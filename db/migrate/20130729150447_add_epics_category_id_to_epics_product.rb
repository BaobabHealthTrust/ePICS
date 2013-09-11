class AddEpicsCategoryIdToEpicsProduct < ActiveRecord::Migration
  def self.up
    add_column :epics_products, :epics_product_category_id, :integer, :after => :epics_product_units_id
  end

  def self.down
    remove_column :epics_products, :epics_product_category_id
  end
end
