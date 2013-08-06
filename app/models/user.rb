class User < ActiveRecord::Base
  require "yaml"
  establish_connection(YAML.load_file("config/database.yml")['openmrs'] )
end
