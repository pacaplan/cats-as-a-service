# frozen_string_literal: true

module CatContent
  # Image media for a cat listing
  class CatMedia < Rampart::Domain::ValueObject
    attribute :url, Rampart::Types::String.optional.default(nil)
    attribute :alt, Rampart::Types::String.optional.default(nil)

    def to_h
      {
        url: url,
        alt: alt
      }
    end

    def self.from(url:, alt: nil)
      new(url: url, alt: alt)
    end
  end
end


