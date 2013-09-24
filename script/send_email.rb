  require 'rubygems'
  require 'rest-client'
  require 'json'
  require 'rails'
  AppPort = 80
  LogErr = Logger.new("/var/www/ePICS/log/send_email.txt")
begin
  RestClient.get("http://test:admin@localhost:#{AppPort}/contact/send_email")
rescue => e
  puts e.inspect
end