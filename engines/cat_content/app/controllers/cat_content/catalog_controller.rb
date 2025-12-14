# frozen_string_literal: true

module CatContent
  class CatalogController < ActionController::API
    # GET /catalog
    # Returns paginated list of published cat listings
    def index
      query = Queries::ListCatListingsQuery.new(
        tags: parse_tags(params[:tags]),
        page: params[:page]&.to_i || 1,
        per_page: [params[:per_page]&.to_i || 20, 100].min
      )

      paginated = cat_listing_service.list(query)

      render json: {
        cats: paginated.items.map { |c| serializer(c).as_json },
        meta: paginated.to_meta
      }
    end

    # GET /catalog/:slug
    # Returns full details of a single cat by slug
    def show
      cat = cat_listing_service.get_by_slug(params[:slug])

      if cat
        render json: serializer(cat).as_json_full
      else
        render json: {
          error: {
            code: "cat_not_found",
            message: "The requested cat does not exist",
            details: { slug: params[:slug] }
          }
        }, status: :not_found
      end
    end

    private

    def cat_listing_service
      @cat_listing_service ||= Infrastructure::Wiring::Container.resolve(:cat_listing_service)
    end

    def serializer(cat)
      Infrastructure::Http::Serializers::CatListingSerializer.new(cat)
    end

    def parse_tags(tags_param)
      return [] if tags_param.nil? || tags_param.empty?
      return tags_param if tags_param.is_a?(Array)
      tags_param.to_s.split(",").map(&:strip).reject(&:empty?)
    end
  end
end

