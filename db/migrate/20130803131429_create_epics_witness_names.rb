class CreateEpicsWitnessNames < ActiveRecord::Migration
  def self.up
    create_table :epics_witness_names do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_witness_names
  end
end
