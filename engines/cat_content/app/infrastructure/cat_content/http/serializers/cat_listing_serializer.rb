# frozen_string_literal: true

module CatContent
  # Serializes CatListing domain objects to JSON-compatible hashes
  class CatListingSerializer
    class << self
      # Serialize a single cat listing for the show endpoint
      #
      # @param listing [CatListing]
      # @return [Hash]
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

      # Serialize a collection of cat listings for the index endpoint
      #
      # @param listings [Array<CatListing>]
      # @return [Hash]
      def serialize_collection(listings)
        {
          listings: listings.map { |listing| serialize(listing) },
          count: listings.size
        }
      end
    end
  end
end

