require "rollbar/rails"

Rollbar.configure do |config|
  config.access_token = AppConfig.rollbar_token
  
  config.exception_level_filters.merge!({
    'ActionController::RoutingError' => lambda do |error|
      error.message.include?('apple-touch-icon') ? 'ignore' : 'error'
    end
  })
  
  config.enabled = false if Rails.env.test? || Rails.env.development?
end
