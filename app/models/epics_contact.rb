class EpicsContact < ActiveRecord::Base
  set_table_name :epics_contacts
  set_primary_key :epics_contact_id
  default_scope where("#{table_name}.voided = 0")

  def self.send_email
    file_name = 'current_report.pdf'
    if File.exist?("/tmp/#{file_name}")
      EpicsContact.where(:voided => false).each do |contact|
        subject = "Epics Report"
        body = "Dear #{contact.title} #{contact.first_name}  #{contact.last_name} <br /><br /> Please find
                attached a report for today"
        Notifications.notify(contact,subject,body,file_name).deliver
      end
    else
      subject = "Epics Email Error"
      Notifications.email_error(subject).deliver
    end 
  end
  
end
