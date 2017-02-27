require "rollbar/rails"

Rollbar.configure do |config|
  config.access_token = AppConfig.rollbar_token
  config.exception_level_filters['ActionController::RoutingError'] = 'ignore'
  config.enabled = false if Rails.env.test? || Rails.env.development?
end
