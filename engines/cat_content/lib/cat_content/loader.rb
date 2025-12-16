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
          content_block
          cat_media
          trait_set
          cat_profile
          paginated_result
        ])

        # Events
        load_files(domain.join("events"), %w[
          cat_listing_published
          cat_listing_archived
          custom_cat_created
          custom_cat_archived
          cat_description_regenerated
        ])

        # Aggregates
        load_files(domain.join("aggregates"), %w[cat_listing custom_cat])

        # Ports
        load_files(domain.join("ports"), %w[
          cat_listing_repository
          custom_cat_repository
          language_model_port
          clock_port
          id_generator_port
          transaction_port
          event_bus_port
        ])
      end

      def load_application_layer(root)
        app = root.join("app/application/cat_content")

        # Commands
        load_files(app.join("commands"), %w[
          create_cat_listing_command
          update_cat_listing_command
          publish_cat_listing_command
          archive_cat_listing_command
          generate_custom_cat_command
          regenerate_description_command
        ])

        # Queries
        load_files(app.join("queries"), %w[list_cat_listings_query])

        # Services
        load_files(app.join("services"), %w[cat_listing_service custom_cat_service])
      end

      def load_infrastructure_layer(root)
        infra = root.join("app/infrastructure/cat_content")

        # Models and Controllers are autoloaded by Rails from app/models and app/controllers
        # No need to manually load them here

        # Adapters
        load_files(infra.join("adapters"), %w[
          system_clock_adapter
          uuid_id_generator_adapter
          database_transaction_adapter
          open_ai_api_language_model_adapter
          event_bus_adapter
        ])

        # Persistence
        load_files(infra.join("persistence/mappers"), %w[cat_listing_mapper custom_cat_mapper])
        load_files(infra.join("persistence/repositories"), %w[sql_cat_listing_repository sql_custom_cat_repository])

        # Wiring (DI container)
        load_files(infra.join("wiring"), %w[container])

        # HTTP Serializers
        load_files(infra.join("http/serializers"), %w[cat_listing_serializer custom_cat_serializer])
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

