class AddMovementToEpicsProduct < ActiveRecord::Migration
  def self.up
    add_column :epics_products, :movement, :boolean, :after => :max_stock
  end

  def self.down
    remove_column :epics_products, :movement
  end
end
