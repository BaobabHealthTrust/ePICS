# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
EPICS::Application.initialize!

ActiveSupport::Inflector.inflections { |i| 
  i.irregular 'epics_stock_details', 'epics_stock_details' 
}
