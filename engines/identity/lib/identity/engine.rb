# frozen_string_literal: true

require "rampart"

module Identity
  class Engine < ::Rails::Engine
    isolate_namespace Identity

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end

    # Set up hexagonal architecture loading (autoload paths, Zeitwerk collapse, load order)
    Rampart::EngineLoader.setup(self)

    # Ensure Devise is loaded early
    initializer "identity.devise", before: :load_config_initializers do
      require "devise"
    end
  end
end
