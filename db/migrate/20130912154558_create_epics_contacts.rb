class CreateEpicsContacts < ActiveRecord::Migration
  def self.up
    create_table :epics_contacts do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :email_address

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_contacts
  end
end
