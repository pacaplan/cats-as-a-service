# frozen_string_literal: true

module CatContent
  # Port for CatListing persistence
  #
  # Implementations:
  # - SqlCatListingRepository (production)
  class CatListingRepository < Rampart::Ports::SecondaryPort
    abstract_method :find_by_slug
    abstract_method :find_all_published
  end
end

