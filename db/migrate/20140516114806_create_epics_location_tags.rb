class CreateEpicsLocationTags < ActiveRecord::Migration
  def self.up
    create_table :epics_location_tags,:primary_key => :location_tag_id do |t|

      t.integer :location_id, :null => false

    end
  end

  def self.down
    drop_table :epics_location_tags
  end
end
