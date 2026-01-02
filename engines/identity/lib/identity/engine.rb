require_relative "loader"

module Identity
  class Engine < ::Rails::Engine
    isolate_namespace Identity

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end

    # Add hexagonal layer directories to autoload paths
    # (Zeitwerk can't auto-resolve due to directory/namespace mismatch,
    # but this enables require_dependency to work)
    initializer "identity.autoload_paths", before: :set_autoload_paths do |app|
      app.config.autoload_paths << root.join("app/domain")
      app.config.autoload_paths << root.join("app/application")
      app.config.autoload_paths << root.join("app/infrastructure")

      app.config.eager_load_paths << root.join("app/domain")
      app.config.eager_load_paths << root.join("app/application")
      app.config.eager_load_paths << root.join("app/infrastructure")
    end

    # Ensure Devise is loaded early
    initializer "identity.devise", before: :load_config_initializers do
      require "devise"
    end

    # Load all hexagonal architecture components
    # The directory structure (app/{layer}/identity/) doesn't match
    # Ruby namespace conventions, so we use a structured loader
    config.to_prepare do
      Identity::Loader.load_all(Identity::Engine.root)
    end
  end
end

