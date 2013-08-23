class CreateEpicsGlobalProperty < ActiveRecord::Migration
  def self.up
    create_table :epics_global_property, :id => false do |t|
      t.string :property
      t.string :property_value
      t.string :description
    end
    execute "ALTER TABLE epics_global_property ADD PRIMARY key (property)"
  end
  def self.down
    drop_table :epics_global_property
  end
end
