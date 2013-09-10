class CreateEpicsRoles < ActiveRecord::Migration
  def self.up
    create_table :epics_roles, :primary_key => :epics_role_id do |t|
      t.string :role
      t.string :description
    end
  end

  def self.down
    drop_table :epics_roles
  end
end
