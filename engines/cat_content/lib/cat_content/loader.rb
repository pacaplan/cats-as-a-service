# frozen_string_literal: true

# Hexagonal Architecture Loader
#
# This module handles loading all the domain, application, and infrastructure
# components in the correct order. The directory structure (app/{layer}/cat_content/)
# doesn't match Ruby namespace conventions, so we use explicit loading.
#
# Load order:
# 1. Rampart framework
# 2. Domain Layer (value objects, entities, aggregates, ports)
# 3. Application Layer (queries, services)
# 4. Infrastructure Layer (persistence, http, wiring)

module CatContent
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
        domain = root.join("app/domain/cat_content")
        
        # Errors
        load_files(domain, %w[resource_not_found])

        # Value Objects (order matters - some depend on others)
        load_files(domain.join("value_objects"), %w[
          cat_id
          cat_name
          slug
          money
          tag_list
          visibility
          cat_media
        ])

        # Events
        load_files(domain.join("events"), %w[
          cat_listing_published
          cat_listing_archived
        ])

        # Aggregates
        load_files(domain.join("aggregates"), %w[cat_listing])

        # Ports
        load_files(domain.join("ports"), %w[
          cat_listing_repository
        ])
      end

      def load_application_layer(root)
        app = root.join("app/application/cat_content")

        # Services
        load_files(app.join("services"), %w[cat_listing_service])
      end

      def load_infrastructure_layer(root)
        infra = root.join("app/infrastructure/cat_content")

        # Models and Controllers are autoloaded by Rails from app/models and app/controllers
        # No need to manually load them here

        # Persistence Models
        load_files(infra.join("persistence/models"), %w[cat_listing_record])

        # Persistence Mappers
        load_files(infra.join("persistence/mappers"), %w[cat_listing_mapper])

        # Persistence Repositories
        load_files(infra.join("persistence/repositories"), %w[sql_cat_listing_repository])

        # Wiring (DI container)
        load_files(infra.join("wiring"), %w[container])

        # HTTP Serializers
        load_files(infra.join("http/serializers"), %w[cat_listing_serializer])
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

