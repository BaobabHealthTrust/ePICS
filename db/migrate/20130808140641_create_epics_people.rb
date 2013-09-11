class CreateEpicsPeople < ActiveRecord::Migration
  def self.up
    create_table :epics_people, :primary_key => :epics_person_id do |t|
      t.string :fname, :null => false
      t.string :lname, :null => false
      t.boolean :has_authority, :null => false, :default => false
      t.boolean :voided, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :epics_people
  end
end
