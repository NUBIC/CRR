# config valid only for Capistrano 3.6.0
lock '3.6.0'

APP_CONFIG = YAML.load(File.open('config/config.yml'))

set :application,  APP_CONFIG['application']
set :repo_url,     APP_CONFIG['repository']

set :rvm_type, :system
set :rvm_ruby_version, '2.1.2'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/var/www/apps/#{ fetch(:application) }"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

set :conditionally_migrate, true  # Defaults to false

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system db_backups}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :migrate_env, "#{ fetch(:stage) }"

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      execute :mkdir, '-p', release_path.join('tmp')
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  task :httpd_graceful do
    on roles(:web), in: :sequence, wait: 5 do
      execute :sudo, "service httpd graceful"
    end
  end
end

namespace :deploy_prepare do
  desc 'Configure virtual host'
  task :create_vhost do
    on roles(:web), in: :sequence, wait: 5 do
      vhost_config = <<-EOF
NameVirtualHost *:80
NameVirtualHost *:443

<VirtualHost *:80>
  ServerName #{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }
  ServerAlias #{ APP_CONFIG[ fetch(:stage).to_s ]['server_alias'] }
  Redirect permanent / https://#{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }/
</VirtualHost>

<VirtualHost *:443>
  PassengerFriendlyErrorPages off
  PassengerAppEnv #{ fetch(:stage) }
  PassengerRuby /usr/local/rvm/wrappers/ruby-#{ fetch(:rvm_ruby_version) }/ruby

  ServerName #{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }

  SSLEngine On
  SSLCertificateFile /etc/pki/tls/certs/crr-prod.cer
  SSLCertificateChainFile /etc/pki/tls/certs/crr-prod-interim.cer
  SSLCertificateKeyFile /etc/pki/tls/private/crr.key

  DocumentRoot #{ fetch(:deploy_to) }/current/public
  RailsBaseURI /
  PassengerDebugLogFile /var/log/httpd/#{ fetch(:application) }_passenger.log

  <Location /admin >
    Order deny,allow
    Deny from all
    Allow from 129.105.0.0/16 165.124.0.0/16
  </Location>

  <Directory #{ fetch(:deploy_to) }/current/public >
    Allow from all
    Options -MultiViews
  </Directory>
</VirtualHost>
EOF
      execute :echo, "\"#{ vhost_config }\"", ">", "/etc/httpd/conf.d/#{ fetch(:application) }.conf"
    end
  end
end

after "deploy:updated", "deploy:cleanup"
after "deploy:finished", "deploy_prepare:create_vhost"
after "deploy_prepare:create_vhost", "deploy:httpd_graceful"
after "deploy:httpd_graceful", "deploy:restart"