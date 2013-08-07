class CreateEpicsExchanges < ActiveRecord::Migration
  def self.up
    create_table :epics_exchanges, :primary_key => :epics_exchange_id do |t|
      t.integer :epics_stock_id, :null => false
      t.integer :epics_order_id, :null => false
      t.integer :epics_location_id, :null => false
      t.date :epics_exchange_date, :null => false
      t.integer :creator, :null => false
      t.boolean :voided, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :epics_exchanges
  end
end
