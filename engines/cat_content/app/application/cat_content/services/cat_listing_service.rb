# frozen_string_literal: true

module CatContent
  # Application service for CatListing operations
  #
  # Orchestrates domain logic for browsing the catalog.
  class CatListingService < Rampart::Application::Service
    def initialize(cat_listing_repo:)
      @cat_listing_repo = cat_listing_repo
    end

    # List all published cat listings
    #
    # @return [Result<Array<CatListing>>]
    def list_published
      listings = @cat_listing_repo.find_all_published
      Success(listings)
    rescue StandardError => e
      Failure(e)
    end

    # Find a single published cat listing by slug
    #
    # @param slug [String] the URL slug
    # @return [Result<CatListing>]
    def find_by_slug(slug)
      listing = @cat_listing_repo.find_by_slug(slug)

      if listing.nil?
        Failure(ResourceNotFound.new(resource_type: "CatListing", identifier: slug))
      elsif !listing.published?
        Failure(ResourceNotFound.new(resource_type: "CatListing", identifier: slug))
      else
        Success(listing)
      end
    rescue StandardError => e
      Failure(e)
    end
  end
end



