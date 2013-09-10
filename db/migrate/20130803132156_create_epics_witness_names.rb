class CreateEpicsWitnessNames < ActiveRecord::Migration
  def self.up
    create_table :epics_witness_names, :primary_key => :epics_witness_name_id do |t|
      t.integer :epics_stock_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_witness_names
  end
end
