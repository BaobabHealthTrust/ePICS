class CreateEpicsGlobalProperty < ActiveRecord::Migration
  def self.up
    create_table :epics_global_property, :primary_key => :property do |t|
      t.string :property_value
      t.string :description
    end
  end

  def self.down
    drop_table :epics_global_property
  end
end
