# config valid only for Capistrano 3.1
lock '3.2.1'

APP_CONFIG = YAML.load(File.open('config/config.yml'))

set :stage, :production
set :app_host,    APP_CONFIG[ fetch(:stage).to_s ]['app_host']
set :app_server,  "#{APP_CONFIG['deployer']}@#{ fetch(:app_host) }"

role :web, fetch(:app_server)
role :db, fetch(:app_server)