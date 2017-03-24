set :application, "reminders"
set :repo_url,  "git://github.com/netguru/reminders.git"
set :deploy_to, "/home/deploy/apps/#{fetch(:application)}"
