class Notifications < ActionMailer::Base
	include SendGrid
  default :from => "epics@baobabhealth.org"
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack
  sendgrid_unique_args :key1 => Time.now, :key2 => Time.now

  def notify(contact,subject,body,file_name)
	 sendgrid_category "Report"
	 sendgrid_unique_args :key2 => Time.now, :key3 => Time.now
     attachments["#{file_name}"] = File.read("/tmp/#{file_name}") rescue nil
     @subject = subject
     @email_body = body
     mail(:to => contact.email_address, :subject => @subject)
  end

  def email_error(subject)
    sendgrid_category "Email Error"
	  sendgrid_unique_args :key2 => Time.now, :key3 => Time.now
    @subject = subject
    mail(:to => "epics@baobabhealth.org", :subject => @subject)
  end

end
