# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'active_support'
require 'factory_bot' # test data
require 'capybara/rails' # integration tests w/ browser
require 'capybara/rspec'
require 'devise'
require 'pundit/rspec'
require 'pundit/matchers'
require 'paper_trail/frameworks/rspec'
Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.server = :webrick
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = Rails.root.join('spec/fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # LOAD SEEDS IF WE NEED THEM
  # config.before(:suite) do
  #   Rails.application.load_seed
  # end

  # DEVISE
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Warden::Test::Helpers

  config.append_after(:each) do
    Warden.test_reset!
  end

  # CapybaraSelect2
  config.include CapybaraSelect2
  config.include CapybaraSelect2::Helpers # if need specific helpers

  # Pause for AJAX actions to complete
  # See: https://thoughtbot.com/blog/automatically-wait-for-ajax-with-capybara
  config.include WaitForAjax, type: :system

  # Pause for Turbo actions to complete
  config.include WaitForTurbo, type: :system

  # i18n / locales
  config.include AbstractController::Translation

  # use dom_id helper in system specs
  config.include ActionView::RecordIdentifier, type: :system
end

APPLICATION_NAME = COMPETITIONS_CONFIG[:application_name]
REGISTERED_USER_LOGIN_BUTTON_TEXT = "Continue with your #{APPLICATION_NAME} account"

SUBMITTED_TEXT  = I18n.t('activerecord.attributes.review.state.submitted')
ASSIGNED_TEXT   = I18n.t('activerecord.attributes.review.state.assigned')
DRAFT_TEXT      = I18n.t('activerecord.attributes.review.state.draft')

def pause(time: 0.25)
  sleep(time)
end

def scroll_to_bottom_of_the_page
  page.execute_script 'window.scrollBy(0,10000)'
end

def scroll_to_half_of_the_page
  page.execute_script 'window.scrollBy(0,2000)'
end

def tom_select_input(label_dom_id:, value:, select_option: true)
  find(label_dom_id).click

  send_keys(value)
  pause(time: 0.75) # The lowest viable time

  if select_option == true
    send_keys(:tab)
    pause
  end
end
