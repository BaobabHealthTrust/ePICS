class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.title :string
      t.first_name :string
      t.last_name :string
      t.phone_number :string
      t.email_address :string

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
