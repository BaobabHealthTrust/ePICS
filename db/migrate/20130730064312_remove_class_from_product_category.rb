class RemoveClassFromProductCategory < ActiveRecord::Migration
  def self.up
    remove_column :epics_product_category, :class
  end

  def self.down
    add_column :epics_product_category, :class, :string, :after => :epics_product_category_id
  end
end
