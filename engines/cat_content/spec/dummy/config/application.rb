# frozen_string_literal: true

require "rails/all"

Bundler.require(*Rails.groups)
require "cat_content"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.api_only = true
    config.eager_load = false
    
    # Configure database path for the dummy app
    config.paths["config/database"] = File.expand_path("../database.yml", __FILE__)
  end
end

