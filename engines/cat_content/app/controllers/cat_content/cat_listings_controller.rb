# frozen_string_literal: true

module CatContent
  # Controller for public catalog browsing
  #
  # Endpoints:
  # - GET /catalog - List all published cat listings
  # - GET /catalog/:slug - Show a single cat listing
  class CatListingsController < CatContent::ApplicationController
    # GET /catalog
    #
    # Returns all published cat listings
    def index
      result = cat_listing_service.list_published

      if result.success?
        render json: serialize_collection(result.value!)
      else
        handle_failure(result.failure)
      end
    end

    # GET /catalog/:slug
    #
    # Returns a single cat listing by slug
    def show
      result = cat_listing_service.find_by_slug(params[:slug])

      if result.success?
        render json: serialize(result.value!)
      elsif not_found?(result.failure)
        render json: {
          error: "not_found",
          message: "Cat listing not found"
        }, status: :not_found
      else
        handle_failure(result.failure)
      end
    end

    private

    def cat_listing_service
      @cat_listing_service ||= CatContent::Container[:cat_listing_service]
    end

    def serialize(listing)
      {
        id: listing.id,
        name: listing.name.to_s,
        slug: listing.slug,
        description: listing.description.to_s,
        price: listing.price.to_h,
        image: listing.image.to_h,
        tags: listing.tags.to_a
      }
    end

    def serialize_collection(listings)
      {
        listings: listings.map { |listing| serialize(listing) },
        count: listings.size
      }
    end

    def not_found?(failure)
      # Check by class name string to avoid importing domain layer
      failure.class.name == "CatContent::ResourceNotFound"
    end

    def handle_failure(error)
      Rails.logger.error("Catalog error: #{error.message}")

      render json: {
        error: "service_unavailable",
        message: "Unable to retrieve catalog. Please try again shortly."
      }, status: :service_unavailable
    end
  end
end
