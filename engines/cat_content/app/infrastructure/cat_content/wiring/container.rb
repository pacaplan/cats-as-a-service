# frozen_string_literal: true

require "dry-container"
require "dry-auto_inject"

module CatContent
  # Dependency Injection container for the Cat Content bounded context
  class Container
    extend Dry::Container::Mixin

    # Repositories
    register(:cat_listing_repo) { CatContent::SqlCatListingRepository.new }

    # Services
    register(:cat_listing_service) do
      CatContent::CatListingService.new(
        cat_listing_repo: resolve(:cat_listing_repo)
      )
    end
  end

  # Auto-inject module for dependency injection
  Import = Dry::AutoInject(Container)
end
