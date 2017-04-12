set :application, "reminders"
set :repo_url,  "git://github.com/netguru/reminders.git"
set :deploy_to, "/home/deploy/apps/#{fetch(:application)}"

set :capose_commands, lambda {
  [
    "build",
    "run --rm web rake assets:precompile",
    "run --rm web rake db:migrate",
    "up -d",
  ]
}
