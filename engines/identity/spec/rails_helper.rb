# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

# Ensure Devise is loaded before Rails initializes
require "devise"

# Load Rails and the engine by loading a dummy Rails app
require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Run Supabase migrations for test database
RSpec.configure do |config|
  config.before(:suite) do
    # Ensure identity schema exists
    ActiveRecord::Base.connection.execute("CREATE SCHEMA IF NOT EXISTS identity") rescue nil
    
    # Run the migration if table doesn't exist
    unless ActiveRecord::Base.connection.table_exists?("identity.shopper_identities")
      migration_file = File.join(Identity::Engine.root, "../../supabase/migrations/20250101000003_create_identity_schema.sql")
      if File.exist?(migration_file)
        sql = File.read(migration_file)
        ActiveRecord::Base.connection.execute(sql) rescue nil
      end
    end
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Include Devise test helpers
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Use engine routes for request specs
  config.include Identity::Engine.routes.url_helpers

  # Override the app method for request specs to use the engine directly
  config.before(:each, type: :request) do
    @routes = Identity::Engine.routes
  end

  # For request specs, use the dummy app which has full middleware stack
  config.around(:each, type: :request) do |example|
    def app
      Rails.application
    end

    example.run
  end
end

