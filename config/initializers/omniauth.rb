def google_scope
  [
    "userinfo.email",
    "userinfo.profile"
  ].join(" ")
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           AppConfig.omniauth_provider_key,
           AppConfig.omniauth_provider_secret,
           hd: AppConfig.domain,
           scope: google_scope
end
