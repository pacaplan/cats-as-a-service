# frozen_string_literal: true

# Hexagonal Architecture Loader
#
# This module handles loading all the domain, application, and infrastructure
# components in the correct order. The directory structure (app/{layer}/identity/)
# doesn't match Ruby namespace conventions, so we use explicit loading.
#
# Load order:
# 1. Rampart framework
# 2. Domain Layer (aggregates, ports)
# 3. Application Layer (services)
# 4. Infrastructure Layer (persistence, wiring)

module Identity
  module Loader
    class << self
      def load_all(engine_root)
        require "rampart"

        load_domain_layer(engine_root)
        load_application_layer(engine_root)
        load_infrastructure_layer(engine_root)
      end

      private

      def load_domain_layer(root)
        domain = root.join("app/domain/identity")

        # Aggregates
        load_files(domain.join("aggregates"), %w[shopper_identity])

        # Ports
        load_files(domain.join("ports"), %w[shopper_identity_repository])
      end

      def load_application_layer(root)
        app = root.join("app/application/identity")

        # Services
        load_files(app.join("services"), %w[shopper_auth_service])
      end

      def load_infrastructure_layer(root)
        infra = root.join("app/infrastructure/identity")

        # Persistence Base Record (must load before models)
        load_files(infra.join("persistence"), %w[base_record])

        # Persistence Models
        load_files(infra.join("persistence/models"), %w[shopper_identity_record])

        # Persistence Mappers
        load_files(infra.join("persistence/mappers"), %w[shopper_identity_mapper])

        # Persistence Repositories
        load_files(infra.join("persistence/repositories"), %w[devise_shopper_identity_repository])

        # Wiring (DI container)
        load_files(infra.join("wiring"), %w[container])
      end

      def load_files(dir, files)
        files.each do |file|
          path = dir.join("#{file}.rb")
          require_dependency path.to_s if path.exist?
        end
      end
    end
  end
end




