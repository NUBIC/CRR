# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, { standard: 'cron.log'}
set :environment, ENV['RAILS_ENV']

case environment
# when 'staging'
#   every :day, at: '6:00AM' do
#     rake 'notify:expiring_release'
#     rake 'notify:expired_release'
#     rake 'notify:suspended_participants'
#     rake 'notify:annual_followup'
#   end
when 'production'
  every :day, at: '6:00AM' do
    rake 'notify:expiring_release'
    rake 'notify:expired_release'
    rake 'notify:suspended_participants'
    rake 'notify:annual_followup'
    rake 'users:ldap_update'
  end
end
