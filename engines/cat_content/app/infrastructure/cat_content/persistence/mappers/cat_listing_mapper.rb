# frozen_string_literal: true

module CatContent
  # Maps between CatListingRecord (ActiveRecord) and CatListing (Domain)
  class CatListingMapper
    class << self
      # Convert ActiveRecord record to domain aggregate
      #
      # @param record [CatListingRecord]
      # @return [CatListing]
      def to_domain(record)
        return nil if record.nil?

        CatListing.new(
          id: record.id,
          name: CatName.from(record.name),
          slug: record.slug,
          description: CatDescription.from(record.description),
          price: Money.from_cents(record.price_cents, currency: record.currency || "USD"),
          visibility: Visibility.from(record.visibility),
          image: CatMedia.from(url: record.image_url, alt: record.image_alt),
          tags: TagList.from(record.tags || []),
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Convert domain aggregate to hash for ActiveRecord
      #
      # @param aggregate [CatListing]
      # @return [Hash]
      def to_record_attributes(aggregate)
        {
          id: aggregate.id,
          name: aggregate.name.to_s,
          slug: aggregate.slug,
          description: aggregate.description.to_s,
          price_cents: aggregate.price.cents,
          currency: aggregate.price.currency,
          visibility: aggregate.visibility.to_s,
          image_url: aggregate.image.url,
          image_alt: aggregate.image.alt,
          tags: aggregate.tags.to_a
        }
      end
    end
  end
end
