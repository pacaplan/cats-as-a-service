# frozen_string_literal: true

require "dry-container"

module CatContent
  module Infrastructure
    module Wiring
      class Container
        extend Dry::Container::Mixin

        # Adapters
        register(:clock_port) { Adapters::SystemClockAdapter.new }
        register(:id_generator_port) { Adapters::UuidIdGeneratorAdapter.new }
        register(:transaction_port) { Adapters::DatabaseTransactionAdapter.new }
        register(:language_model_port) { Adapters::OpenAIApiLanguageModelAdapter.new }
        register(:event_bus_port) { Adapters::EventBusAdapter.new }

        # Repositories
        register(:cat_listing_repo) do
          Persistence::Repositories::SqlCatListingRepository.new
        end

        register(:custom_cat_repo) do
          Persistence::Repositories::SqlCustomCatRepository.new
        end

        # Application services
        register(:cat_listing_service) do
          Services::CatListingService.new(
            cat_listing_repo: resolve(:cat_listing_repo),
            clock_port: resolve(:clock_port),
            id_generator_port: resolve(:id_generator_port),
            transaction_port: resolve(:transaction_port),
            event_bus_port: resolve(:event_bus_port)
          )
        end

        register(:custom_cat_service) do
          Services::CustomCatService.new(
            custom_cat_repo: resolve(:custom_cat_repo),
            language_model_port: resolve(:language_model_port),
            clock_port: resolve(:clock_port),
            id_generator_port: resolve(:id_generator_port),
            transaction_port: resolve(:transaction_port),
            event_bus_port: resolve(:event_bus_port)
          )
        end
      end
    end
  end
end

