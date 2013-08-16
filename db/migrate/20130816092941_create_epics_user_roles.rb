class CreateEpicsUserRoles < ActiveRecord::Migration
  def self.up
    create_table :epics_user_roles, :primary_key => :epics_user_role_id do |t|

      t.integer :user_id
      t.integer :epics_role_id

    end
  end

  def self.down
    drop_table :epics_user_roles
  end
end
