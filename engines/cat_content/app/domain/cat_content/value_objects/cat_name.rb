# frozen_string_literal: true

module CatContent
  # Name of a cat listing
  class CatName < Rampart::Domain::ValueObject
    attribute :value, Rampart::Types::String.constrained(min_size: 1, max_size: 100)

    def to_s
      value
    end

    def self.from(name)
      new(value: name.to_s)
    end
  end
end
