begin
	require 'rubygems'
	require 'rest-client'
	require 'json'
	require 'rails'
	EpicsContact.send_email
rescue => e
  puts e.inspect
end