require_relative "boot"

require "rails/all"
require 'nested_form/builder_mixin'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Continue using secrets rather than credentials
SECRETS_DATA = begin
  yaml_path = File.expand_path("../secrets.yml", __FILE__)
  if File.exist?(yaml_path)
    # Rails.env might fail if Rails isn't fully booted, fallback to ENV['RAILS_ENV']
    env = ENV["RAILS_ENV"] || "development"
    data = YAML.load(ERB.new(File.read(yaml_path)).result)[env] || {}
    data.deep_symbolize_keys
  else
    {}
  end
end

module Competitions
  class Application < Rails::Application
    config.secrets          = config_for(:secrets) # loads from config/secrets.yml
    config.secret_key_base  = config.secrets[:secret_key_base]

    # Update rails to v7.0.8
    #   Added before `Bundler.require` per deprection warning.
    #   Note: If commented, PaperTrail (v15.1) entries for Grants
    #         will show the following deprecation due to dates in `object`:
    #         `DEPRECATION WARNING: Using a :default format for Date#to_s is deprecated.
    #          Please use Date#to_fs instead.`
    ENV['RAILS_DISABLE_DEPRECATED_TO_S_CONVERSION'] = "true"


    # Require the gems listed in Gemfile, including any gems
    # you've limited to :test, :development, or :production.
    Bundler.require(*Rails.groups)

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # # Configuration for the application, engines, and railties goes here.
    # # These settings can be overridden in specific environments using the files
    # # in config/environments, which are processed later.
    # # Application configuration can go into files in config/initializers
    # # -- all .rb files in that directory are automatically loaded after loading
    # # the framework and any gems in your application.
    # config.eager_load_paths << Rails.root.join("lib")

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])


    # Recursively load locale files
    # Allows for organized, model-specific translation files
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # 03/27/26 - Rails 8 upgrade
    #            Addresses missing :index action in Devise controllers
    #            Moved to SamlSessionsController to allow logout
    # config.action_controller.raise_on_missing_callback_actions = false

    def secrets
      config.secrets
    end
  end
end

competitions_config = File.join(Rails.root, 'config', 'competitions_config.yml')

if File.exist?(competitions_config)
  COMPETITIONS_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load(File.open(competitions_config)))[Rails.env.to_sym]
else
  Rails.logger.error("Warning: Competitions config file is missing. (#{competitions_config})")
end
