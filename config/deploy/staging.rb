server ENV["REMINDERS_STAGING_SERVER_HOST"], user: ENV["REMINDERS_STAGING_SERVER_USER"], roles: %w(web app db)
set :branch, "master"

