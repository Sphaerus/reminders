Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    options = event.payload.slice(:request_id, :user_id)
    options[:params] = event.payload[:params].except("controller", "action")
    options
  end

  config.action_mailer.smtp_settings = {
    user_name: AppConfig.sendgrid_user_name,
    password: AppConfig.sendgrid_password,
    domain: AppConfig.domain,
    address: "smtp.sendgrid.net",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }

  # Access secret base key via AppConfig
  secrets.secret_key_base = AppConfig.secret_key_base
end
