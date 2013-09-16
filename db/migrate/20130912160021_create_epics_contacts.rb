class CreateEpicsContacts < ActiveRecord::Migration
  def self.up
    create_table :epics_contacts, :primary_key => :epics_contact_id do |t|
      t.string :title, :null => false
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.string :phone_number, :null => false
      t.string :email_address, :null => false
      t.boolean :voided, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :epics_contacts
  end
end
