server ENV["REMINDERS_SERVER_HOST"], user: ENV["REMINDERS_SERVER_USER"], roles: %w(web app db)

set :docker_dockerfile, "docker/production/Dockerfile"
