class EpicsContact < ActiveRecord::Base
  set_table_name :epics_contacts
  set_primary_key :epics_contact_id
  default_scope where("#{table_name}.voided = 0")

  def self.send_email
    EpicsContact.where(:voided => false).collect do |contact|
      subject = "Epics Report"
      body = "Dear #{contact.title} #{contact.first_name}  #{contact.last_name} <br /> Please find
              attached a report for today"
			Notifications.notify(contact,subject,body).deliver
    end
  end
  
end
