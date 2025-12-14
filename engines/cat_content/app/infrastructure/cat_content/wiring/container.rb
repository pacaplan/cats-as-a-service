# frozen_string_literal: true

require "dry-container"

module CatContent
  module Infrastructure
    module Wiring
      class Container
        extend Dry::Container::Mixin

        # Repositories
        register(:cat_listing_repo) do
          Persistence::Repositories::SqlCatListingRepository.new
        end

        # Application services
        register(:cat_listing_service) do
          Services::CatListingService.new(
            cat_listing_repo: resolve(:cat_listing_repo)
          )
        end
      end
    end
  end
end

