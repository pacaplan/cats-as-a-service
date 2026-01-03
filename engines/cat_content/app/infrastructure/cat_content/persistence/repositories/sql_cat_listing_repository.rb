# frozen_string_literal: true

module CatContent
  # SQL implementation of CatListingRepository
  class SqlCatListingRepository < CatListingRepository
    # Find all published cat listings
    #
    # @return [Array<CatListing>]
    def find_all_published
      records = CatListingRecord.published.order(created_at: :desc)
      records.map { |record| CatListingMapper.to_domain(record) }
    end

    # Find a cat listing by slug
    #
    # @param slug [String]
    # @return [CatListing, nil]
    def find_by_slug(slug)
      record = CatListingRecord.find_by(slug: slug)
      CatListingMapper.to_domain(record)
    end
  end
end
