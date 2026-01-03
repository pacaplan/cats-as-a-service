# frozen_string_literal: true

module CatContent
  # Unique identifier for a cat listing
  class CatId < Rampart::Domain::ValueObject
    attribute :value, Rampart::Types::String

    def to_s
      value
    end

    def self.from(id)
      new(value: id.to_s)
    end
  end
end
