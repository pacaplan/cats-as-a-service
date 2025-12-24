# frozen_string_literal: true

module CatContent
  # SQL implementation of CatListingRepository
  class SqlCatListingRepository < CatListingRepository
    # Find all published cat listings
    #
    # @return [Array<CatListing>]
    def find_all_published
      records = CatContent::CatListingRecord.published.order(created_at: :desc)
      records.map { |record| CatContent::CatListingMapper.to_domain(record) }
    end

    # Find a cat listing by slug
    #
    # @param slug [String]
    # @return [CatListing, nil]
    def find_by_slug(slug)
      record = CatContent::CatListingRecord.find_by(slug: slug)
      CatContent::CatListingMapper.to_domain(record)
    end
  end
end

