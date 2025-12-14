# frozen_string_literal: true

module CatContent
  module Services
    class CatListingService < Rampart::Application::Service
      def initialize(cat_listing_repo:)
        @cat_listing_repo = cat_listing_repo
      end

      # Browse/filter Cat-alog
      # @return [PaginatedResult] paginated list of public cat listings
      def list(query)
        @cat_listing_repo.list_public(
          tags: query.tags,
          page: query.page,
          per_page: query.per_page
        )
      end

      # Retrieve single cat details by slug
      # @return [CatListing, nil] the cat listing or nil if not found
      def get_by_slug(slug)
        @cat_listing_repo.find_by_slug(slug)
      end
    end
  end
end

