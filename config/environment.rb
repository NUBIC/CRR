# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
AudiologyRegistry::Application.initialize!
AudiologyRegistry::Application.config.crr_website_url = 'http://commresearchregistry.northwestern.edu/'
