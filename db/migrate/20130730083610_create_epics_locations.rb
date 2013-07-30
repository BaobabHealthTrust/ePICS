class CreateEpicsLocations < ActiveRecord::Migration
  def self.up
    create_table :epics_locations do |t|
      t.string :name
      t.string :description
      t.integer :epics_location_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_locations
  end
end
