# Load the rails application
require File.expand_path('../application', __FILE__)
APP_VERSION = `git describe`.gsub("\n", "")
# Initialize the rails application
EPICS::Application.initialize!

ActiveSupport::Inflector.inflections { |i| 
  i.irregular 'epics_stock_details', 'epics_stock_details' 
  i.irregular 'epics_locations', 'epics_locations'
  i.irregular 'epics_product_orders', 'epics_product_orders'
}

bart = (YAML.load_file("config/database.yml")['openmrs'] )
User.establish_connection(bart)
OpenmrsPerson.establish_connection(bart)
OpenmrsPersonName.establish_connection(bart)
