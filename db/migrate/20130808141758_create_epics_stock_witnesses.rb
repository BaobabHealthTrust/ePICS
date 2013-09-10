class CreateEpicsStockWitnesses < ActiveRecord::Migration
  def self.up
    create_table :epics_stock_witnesses, :primary_key => :epics_stock_witness_id do |t|
      t.integer :epics_stock_id
      t.integer :epics_person_id
      t.timestamps
    end
  end

  def self.down
    drop_table :epics_stock_witnesses
  end
end
