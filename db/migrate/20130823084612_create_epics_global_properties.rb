class CreateEpicsGlobalProperties < ActiveRecord::Migration
  def self.up
    create_table :epics_global_properties do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_global_properties
  end
end
