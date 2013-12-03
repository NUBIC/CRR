# -*- coding: utf-8 -*-
require 'bundler/capistrano'
require 'bcdatabase'
load 'deploy/assets'

bcconf = Bcdatabase.load["crr_deploy", :crr] # Using the bcdatabase gem for server config
set :application, "crr"

# User
set :use_sudo, false
#set :default_shell, "bash"
ssh_options[:forward_agent] = true

# Version control
default_run_options[:pty]   = true # to get the passphrase prompt from git

set :scm, "git"
set :repository, bcconf["repo"] #"ssh://code.bioinformatics.northwestern.edu/git/audiology_registry.git"
set :branch do
  # http://nathanhoad.net/deploy-from-a-git-tag-with-capistrano
  puts "Tags: " + `git tag`.split("\n").join(", ")
  puts "Remember to push tags first: git push origin --tags"
  ref = Capistrano::CLI.ui.ask "Tag, branch, or commit to deploy [master]: "
  ref.empty? ? "master" : ref
end
set :deploy_to, "/var/www/apps/crr" #bcconf["deploy_to"]
set :deploy_via, :remote_cache

task :set_roles do
  role :app, app_server
  role :web, app_server
  role :db, app_server, :primary => true
end

desc "Deploy to staging"
task :staging do
  set :app_server, bcconf["staging_app_server"] #"clinical-rails-staging2.nubic.northwestern.edu"
  set :rails_env, "staging"
  set :prefix_env, "/#{application}"
  set_roles
end

namespace :deploy do
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "Fix permissions"
  task :permissions do
    sudo "chmod -R g+w #{shared_path} #{current_path} #{release_path}"
  end

end

#after 'deploy:update_code', 'web:static', 'deploy:permissions','deploy:cleanup'
after 'deploy:finalize_update', 'deploy:permissions'