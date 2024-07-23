# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'pg'
gem 'rails', '~> 7.0.8'

# Use SCSS for stylesheets
gem 'dartsass-sprockets'
# Use Terser as compressor for JavaScript assets
gem 'terser', '~> 1.1'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'hotwire-rails'
gem 'jsbundling-rails', '~> 1.3'
gem 'requestjs-rails'
gem 'turbo-rails', '~> 2.0.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap',                     '>= 1.17.0', require: false

gem 'devise',                       '4.9.3'
gem 'devise_saml_authenticatable',  '~> 1.9.1'
gem 'pundit',                       '~> 2.3.1'
gem 'rubyzip',                      '~> 2.3.2'

# frontend
gem 'font-awesome-rails'
gem 'foundation-datepicker-rails'
gem 'foundation-rails',             '~> 6.5.3.0'
gem 'friendly_id',                  '~> 5.5.0'
gem 'haml-rails',                   '~> 2.0'
gem 'jquery-rails',                 '~> 4.6.0'
gem 'jquery-ui-rails',              '~> 7.0.0'
gem 'pagy',                         '~> 6.2.0'
gem 'ransack',                      '~> 3.2.1'
gem 'sprockets-es6'

# audits
gem 'discard',                      '~> 1.3'
gem 'paper_trail',                  '~> 15.1.0'

gem 'exception_notification'

gem 'american_date',                '~> 1.3'
gem 'validates_timeliness',         '7.0.0.beta2'

# form_builder
gem 'cocoon'
gem 'nested_form'
# gem "select2-rails"

# s3
gem 'aws-sdk-s3', require: false

# exports
gem 'caxlsx', '~> 3.3'
gem 'caxlsx_rails'
gem 'wicked_pdf',                   '~> 2.1.0'
gem 'wkhtmltopdf-binary',           '~> 0.12.6'

group :development, :test do
  gem 'awesome_print'
  gem 'byebug',       platforms: %i[mri mingw x64_mingw]
  gem 'puma',         '~> 5.6.8'
  gem 'rspec-rails',  '~> 6.1.3'
  gem 'webrick',      '1.8.1'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'i18n-debug'
  gem 'listen', '~> 3.5.1'
  gem 'rubocop'
  gem 'spring',                 '~> 4.0.0'
  gem 'spring-watcher-listen',  '~> 2.1.0'
  gem 'web-console',            '>= 3.3.0'

  # Use Capistrano for deployment
  gem 'capistrano',       require: false
  gem 'capistrano-passenger'
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-service'
end

group :test do
  gem 'capybara', '~> 3.39.2'
  gem 'capybara-select-2'
  gem 'factory_bot_rails'
  gem 'faker',                    '~> 3.2.2'
  gem 'pundit-matchers',          '~> 3.1.2'
  gem 'rails-controller-testing'
  gem 'rspec',                    '3.13.0'
  gem 'selenium-webdriver',       '~> 4.16.0'
  gem 'simplecov',                '~> 0.22', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
