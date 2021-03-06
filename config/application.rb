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
  end
end

competitions_config = File.join(Rails.root, 'config', 'competitions_config.yml')

if File.exists?(competitions_config)
  COMPETITIONS_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load(File.open(competitions_config)))[Rails.env.to_sym]
else
  Rails.logger.error("Warning: Competitions config file is missing. (#{competitions_config})")
end