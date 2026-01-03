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
        render json: CatListingSerializer.serialize_collection(result.value!)
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
        render json: CatListingSerializer.serialize(result.value!)
      elsif result.failure.is_a?(ResourceNotFound)
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
      @cat_listing_service ||= Container.resolve(:cat_listing_service)
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
