class AddEpicsLocationIdToEpicsStockDetails < ActiveRecord::Migration
  def self.up
     add_column :epics_stock_details, :epics_location_id, :integer, :after => :epics_products_id
     remove_column :epics_stock_details, :location
  end

  def self.down
    remove_column :epics_stock_details, :epics_location_id
    add_column :epics_stock_details, :location, :integer, :after => :epics_products_id
  end
end
