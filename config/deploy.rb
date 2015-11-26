Airbrussh.configure do |config|
  config.command_output = true
end

set :application, "reminders"
set :repo_url,  "git://github.com/netguru/reminders.git"
set :deploy_to, ENV["REMINDERS_DEPLOY_PATH"]

set :docker_copy_data, %w(config/secrets.yml)
set :docker_volumes, -> { ["#{fetch(:deploy_to)}/shared/log:/var/www/app/log"] }
set :docker_additional_options, -> { "--env-file #{fetch(:deploy_to)}/shared/envfile" }
set :docker_apparmor_profile, "docker-ptrace"
