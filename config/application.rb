require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module AudiologyRegistry
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'config.yml')
      APP_CONFIG = YAML.load(File.open(env_file))
    end
    config.custom = ActiveSupport::OrderedOptions.new
    config.custom.app_config = APP_CONFIG

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.action_mailer.smtp_settings = { :address => "smtprelay.northwestern.edu", :port => 25, :domain => "northwestern.edu" }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.default_url_options = { :host => "http#{'s' unless Rails.env == 'development'}://#{config.custom.app_config[Rails.env]['server_name']}" }

    Aker.configure do
      ui_mode :cas
    end
  end
end
