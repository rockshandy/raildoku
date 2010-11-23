# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Raildoku::Application.initialize!

# Set Haml format
Haml::Template.options[:format] = :html5

