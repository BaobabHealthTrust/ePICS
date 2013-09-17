begin
	require 'rubygems'
	require 'rest-client'
	require 'json'
	require 'rails'
  report = ReportController.new
  report.items_to_expire_next_six_months_to_pdf
  report.daily_dispensation_to_pdf
  report.daily_dispensation_to_pdf
  report.received_items_to_pdf
	EpicsContact.send_email
rescue => e
  puts e.inspect
end