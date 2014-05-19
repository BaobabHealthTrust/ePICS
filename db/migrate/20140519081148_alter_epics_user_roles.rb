class AlterEpicsUserRoles < ActiveRecord::Migration
  def self.up
    add_column :epics_user_roles,:voided, :integer, :default => 0
  end

  def self.down
    remove_column :voided
  end
end
