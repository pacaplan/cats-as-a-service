# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

# Load Rails and the engine by loading a dummy Rails app
require File.expand_path("../dummy/config/environment.rb", __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!

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
Dir[File.join(__dir__, "support", "**", "*.rb")].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# We use Supabase migrations, not Rails migrations, so we skip this check
# begin
#   ActiveRecord::Migration.maintain_test_schema!
# rescue ActiveRecord::PendingMigrationError => e
#   abort e.to_s.strip
# end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = Rails.root.join("spec/fixtures")

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
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Include FactoryBot syntax methods
  config.include FactoryBot::Syntax::Methods

  # Use engine routes for request specs
  config.include CatContent::Engine.routes.url_helpers

  # Override the app method for request specs to use the engine directly
  config.before(:each, type: :request) do
    @routes = CatContent::Engine.routes
  end

  # For request specs, use the engine as the app
  config.around(:each, type: :request) do |example|
    # Use engine as the app for this test
    def app
      CatContent::Engine
    end

    example.run
  end

  # Architecture specs avoid touching the database
  config.around(:each, skip_db: true) do |example|
    original = config.use_transactional_fixtures
    original_active_record = config.respond_to?(:use_active_record?) ? config.use_active_record? : true
    config.use_transactional_fixtures = false
    config.use_active_record = false if config.respond_to?(:use_active_record=)
    example.run
  ensure
    config.use_active_record = original_active_record if config.respond_to?(:use_active_record=)
    config.use_transactional_fixtures = original
  end
end
