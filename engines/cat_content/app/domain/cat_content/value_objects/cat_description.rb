# frozen_string_literal: true

module CatContent
  # Description text for a cat listing
  class CatDescription < Rampart::Domain::ValueObject
    attribute :value, Rampart::Types::String.constrained(min_size: 1)

    def to_s
      value
    end

    def self.from(description)
      new(value: description.to_s)
    end
  end
end
