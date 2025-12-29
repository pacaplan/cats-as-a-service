module Identity
  class Engine < ::Rails::Engine
    isolate_namespace Identity

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end

    # Add infrastructure models to autoload paths
    config.autoload_paths += %W[#{config.root}/app/infrastructure]

    # Ensure Devise is loaded early
    initializer "identity.devise", before: :load_config_initializers do
      require "devise"
    end
  end
end

