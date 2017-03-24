server ENV["REMINDERS_SERVER_HOST"], user: ENV["REMINDERS_SERVER_USER"], roles: %w(web app db)
set :branch, "production"

set :capose_commands, -> {
  [
    "build",
    "run --rm web rake assets:precompile",
    "run --rm web rake db:migrate",
    "up -d"
  ]
}
