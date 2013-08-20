class OpenmrsPerson < ActiveRecord::Base
  set_primary_key :person_id
  set_table_name :person
  has_many :openmrs_person_names, :foreign_key => :person_id

  require 'uuidtools'
  def before_save
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.date_created = Time.now
  end

end
