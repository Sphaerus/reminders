source "https://rubygems.org"
gem "rails", "4.2.5"

gem "app_konfig"
gem "coffee-rails"
gem "decent_exposure"
gem "draper"
gem "faker"
gem "jquery-datatables-rails"
gem "jquery-rails", "4.0.4" # version 4.0.5 breaks jquery-datatables
gem "liquid"
gem "lograge"
gem "netguru_theme"
gem "omniauth"
gem "omniauth-google-oauth2", "0.2.9" # lock till the regression is solved
gem "pg"
gem "rollbar"
gem "sass-rails", "~> 5.0"
gem "simple_form"
gem "slack-api"
gem "slim-rails"
gem "thin"
gem "turbolinks"
gem "uglifier", ">= 1.3.0"
gem "whenever"

# deployment

gem "airbrussh", require: false
gem "capistrano"
gem "capistrano-docker", github: "netguru/capistrano-docker", tag: "v0.2.3"

gem "rvm1-capistrano3", require: false

group :development, :test do
  gem "byebug"
  gem "pry-rails"
  gem "pry-rescue"
  gem "web-console"
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "capybara-webkit"
  gem "codeclimate-test-reporter", require: nil
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "launchy"
  gem "poltergeist"
  gem "rspec-html-matchers"
  gem "rspec-rails"
  gem "site_prism"
  gem "shoulda-matchers"
  gem "timecop"
  gem "zonebie"
end

group :development do
  gem "better_errors"
  gem "bullet"
  gem "guard-rails"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "hub", require: nil
  gem "quiet_assets"
  gem "rack-mini-profiler"
  gem "spring"
  gem "spring-commands-rspec"
end
