# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

module Competitions
  class Application < Rails::Application
    # Update rails to v7.0.8
    #   Deprecate passing a format to #to_s in favor of #to_fs
    #   Fixed as needed. Added config before `Bundler.require` per deprection warning.
    ENV['RAILS_DISABLE_DEPRECATED_TO_S_CONVERSION'] = "true"
    
    # Require the gems listed in Gemfile, including any gems
    # you've limited to :test, :development, or :production.
    Bundler.require(*Rails.groups)

    # Initialize configuration defaults
    config.load_defaults 7.0

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

    # Update paper_trail to v15.1
    #   error `Psych::DisallowedClass, Tried to load unspecified class: Time`
    #   Per Rails guide, default setting is [Symbol]
    config.active_record.yaml_column_permitted_classes = [Symbol, Time]
  end
end

competitions_config = File.join(Rails.root, 'config', 'competitions_config.yml')

if File.exists?(competitions_config)
  COMPETITIONS_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load(File.open(competitions_config)))[Rails.env.to_sym]
else
  Rails.logger.error("Warning: Competitions config file is missing. (#{competitions_config})")
end
