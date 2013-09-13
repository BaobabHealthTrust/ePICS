class Notifications < ActionMailer::Base
	include SendGrid
  default :from => "dde@baobabhealth.org"
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack
  sendgrid_unique_args :key1 => Time.now, :key2 => Time.now

  def notify(contact,subject,body)
	 sendgrid_category "Report"
	 sendgrid_unique_args :key2 => Time.now, :key3 => Time.now
   @subject = subject
   @email_body = body
   mail(:to => contact.email_address, :subject => @subject)
  end

end
