require_relative 'boot'

require 'rails/all'

module Competitions
  class Application < Rails::Application
    # Update rails to v7.0.8
    #   Deprecate passing a date to #to_s in favor of #to_fs
    #   Updated in views as needed. 
    #   Added before `Bundler.require` per deprection warning.
    #   Note: PaperTrail (v15.1) entries with date(s) still show the following deprecation 
    #         `DEPRECATION WARNING: Using a :default format for Date#to_s is deprecated. 
    #          Please use Date#to_fs instead.`
    ENV['RAILS_DISABLE_DEPRECATED_TO_S_CONVERSION'] = "true"

    
    # Require the gems listed in Gemfile, including any gems
    # you've limited to :test, :development, or :production.
    Bundler.require(*Rails.groups)

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    # config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join("lib")


    # Recursively load locale files
    # Allows for organized, model-specific translation files
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Update paper_trail to v15.1, Rails 7
    #   error `Psych::DisallowedClass, Tried to load unspecified class: Time`
    #   Per Rails guide, default setting is [Symbol]
    config.active_record.yaml_column_permitted_classes = [Symbol, Time]
  
    config.active_support.disable_to_s_conversion = true
  end
end

competitions_config = File.join(Rails.root, 'config', 'competitions_config.yml')

if File.exists?(competitions_config)
  COMPETITIONS_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load(File.open(competitions_config)))[Rails.env.to_sym]
else
  Rails.logger.error("Warning: Competitions config file is missing. (#{competitions_config})")
end
