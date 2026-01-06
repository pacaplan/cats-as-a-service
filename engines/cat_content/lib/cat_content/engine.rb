# frozen_string_literal: true

require "rampart"

module CatContent
  class Engine < ::Rails::Engine
    isolate_namespace CatContent

    # Configure generators to use UUID primary keys and skip certain files
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: "spec/factories"
    end

    # Set up hexagonal architecture loading (autoload paths, Zeitwerk collapse, load order)
    Rampart::EngineLoader.setup(self)
  end
end
