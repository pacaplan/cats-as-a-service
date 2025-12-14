require_relative "loader"

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
    # (Zeitwerk can't auto-resolve due to directory/namespace mismatch,
    # but this enables require_dependency to work)
    initializer "cat_content.autoload_paths", before: :set_autoload_paths do |app|
      app.config.autoload_paths << root.join("app/domain")
      app.config.autoload_paths << root.join("app/application")
      app.config.autoload_paths << root.join("app/infrastructure")

      app.config.eager_load_paths << root.join("app/domain")
      app.config.eager_load_paths << root.join("app/application")
      app.config.eager_load_paths << root.join("app/infrastructure")
    end

    # Load all hexagonal architecture components
    # The directory structure (app/{layer}/cat_content/) doesn't match
    # Ruby namespace conventions, so we use a structured loader
    config.to_prepare do
      CatContent::Loader.load_all(CatContent::Engine.root)
    end
  end
end
