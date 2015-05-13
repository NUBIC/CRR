# config valid only for Capistrano 3.1
lock '3.2.1'

set :stage, :production
set :app_host,    Rails.configuration.custom.app_config[ fetch(:stage).to_s ]['app_host']
set :app_server,  "#{Rails.configuration.custom.app_config['deployer']}@#{ fetch(:app_host) }"

role :web, fetch(:app_server)
role :db, fetch(:app_server)
