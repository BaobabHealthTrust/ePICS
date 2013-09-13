class Notifications < ActionMailer::Base
	include SendGrid
  default :from => "epics@baobabhealth.org"
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack
  sendgrid_unique_args :key1 => Time.now, :key2 => Time.now

  def notify(contact,subject,body)
	 sendgrid_category "Report"
	 sendgrid_unique_args :key2 => Time.now, :key3 => Time.now
   sendgrid_recipients contacts_to_notify
   @subject = subject
   @email_body = body
   mail(:to => "kch.epics@gmail.com", :subject => @subject)
  end

  def contacts_to_notify
    contacts = EpicsContact.where(:voided => false).collect do |contact|
      contact.email_address
    end
    return contacts
  end
end
