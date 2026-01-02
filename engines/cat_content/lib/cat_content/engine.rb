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

    # Add hexagonal layer directories to autoload paths
    initializer "cat_content.autoload_paths", before: :set_autoload_paths do |app|
      app.config.autoload_paths << root.join("app/domain")
      app.config.autoload_paths << root.join("app/application")
      app.config.autoload_paths << root.join("app/infrastructure")

      app.config.eager_load_paths << root.join("app/domain")
      app.config.eager_load_paths << root.join("app/application")
      app.config.eager_load_paths << root.join("app/infrastructure")
    end

    # Load all hexagonal architecture components using Rampart's generic loader
    # The directory structure (app/{layer}/cat_content/) doesn't match
    # Ruby namespace conventions, so we use Rampart::EngineLoader which auto-discovers files
    config.to_prepare do
      Rampart::EngineLoader.load_all(
        engine_root: CatContent::Engine.root,
        context_name: "cat_content"
      )
    end
  end
end
