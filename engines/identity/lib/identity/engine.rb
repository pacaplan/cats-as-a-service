# frozen_string_literal: true

require "rampart"

module Identity
  class Engine < ::Rails::Engine
    isolate_namespace Identity

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end

    # Ensure Devise is loaded early
    initializer "identity.devise", before: :load_config_initializers do
      require "devise"
    end

    # Add hexagonal layer directories to autoload paths
    initializer "identity.autoload_paths", before: :set_autoload_paths do |app|
      app.config.autoload_paths << root.join("app/domain")
      app.config.autoload_paths << root.join("app/application")
      app.config.autoload_paths << root.join("app/infrastructure")

      app.config.eager_load_paths << root.join("app/domain")
      app.config.eager_load_paths << root.join("app/application")
      app.config.eager_load_paths << root.join("app/infrastructure")
    end

    # Load all hexagonal architecture components using Rampart's generic loader
    # The directory structure (app/{layer}/identity/) doesn't match
    # Ruby namespace conventions, so we use Rampart::EngineLoader which auto-discovers files
    config.to_prepare do
      Rampart::EngineLoader.load_all(
        engine_root: Identity::Engine.root,
        context_name: "identity"
      )
    end
  end
end

