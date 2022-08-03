# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Competitions
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    # config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << "#{config.root}/lib"


    # Recursively load locale files
    # Allows for organized, model-specific translation files
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Specify cookies SameSite protection level: either :none, :lax, or :strict.
    # This change is not backwards compatible with earlier Rails versions.
    # It's best enabled when your entire app is migrated and stable on 6.1.
    # Was not in Rails 6.0. Default in rails 6.1 is :lax, not :strict
    # This suppresses browser messages in console.
    config.action_dispatch.cookies_same_site_protection = :lax

    config.hosts = [
      IPAddr.new("0.0.0.0/0"),        # All IPv4 addresses.
      IPAddr.new("::/0"),             # All IPv6 addresses.
      "localhost",                    # The localhost reserved domain.
      'localhost:3000', '127.0.0.1:3000', 'localhost:8080'
      # ENV["RAILS_DEVELOPMENT_HOSTS"]  # Additional comma-separated hosts for development.
    ]
  end
end

competitions_config = File.join(Rails.root, 'config', 'competitions_config.yml')

if File.exists?(competitions_config)
  COMPETITIONS_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load(File.open(competitions_config)))[Rails.env.to_sym]
else
  Rails.logger.error("Warning: Competitions config file is missing. (#{competitions_config})")
end
