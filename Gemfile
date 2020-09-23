# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'pg'
gem 'rails', '~> 6.0.3.2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'devise', '>= 4.7.1'
gem 'devise_saml_authenticatable', git: 'https://github.com/apokalipto/devise_saml_authenticatable', ref: 'fc398ff'

gem 'draper'
gem 'pundit'
gem 'rubyzip' #, '~> 1.3.0'

# frontend
gem 'font-awesome-rails'
gem 'foundation-datepicker-rails'
gem 'foundation-rails', '~> 6.5.1.0'
gem 'friendly_id', '~> 5.2.4'
gem 'haml-rails', '~> 1.0'
gem 'jquery-rails', '>= 4.3.5'
gem 'jquery-ui-rails'
gem 'pagy', '~> 3.5'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'sprockets-es6'
gem 'trix'

# audits
gem 'discard', '~> 1.2'
gem 'paper_trail'

gem 'american_date'
gem 'validates_timeliness'

# form_builder
gem "cocoon"
gem "nested_form"
gem "select2-rails"

# s3
gem "aws-sdk-s3", require: false

# exports
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

group :development, :test do
  gem 'awesome_print'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'puma', '~> 3.12'

  gem 'rspec-rails', git: 'https://github.com/rspec/rspec-rails', branch: 'main'
  gem 'rspec-core', git: 'https://github.com/rspec/rspec-core'
  gem 'rspec-expectations', git: 'https://github.com/rspec/rspec-expectations'
  gem 'rspec-mocks', git: 'https://github.com/rspec/rspec-mocks'
  gem 'rspec-support', git: 'https://github.com/rspec/rspec-support'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem 'bullet'
  gem 'i18n-debug'
  gem 'listen' #, '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # Use Capistrano for deployment
  gem "capistrano", require: false
  gem "capistrano-rails", require: false
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-service'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'rspec'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
