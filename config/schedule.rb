# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"
#set :environment, 'development'
set :environment, 'production'

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

every :reboot do
  # CentOS VM
  job_type :application, "cd /usr/local/Ruby/payroll_atm && :task :output"
  # Mac Mini
#  job_type :application, "cd /Users/jeremy/Ruby/payment_atm && :task :output"
  
  application "rails server -e production" # Start application server
#  application "bundle exec sidekiq -c 5" # Start background workers
end
