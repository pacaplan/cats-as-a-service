# frozen_string_literal: true

module CatContent
  # URL-safe slug for a cat listing
  class Slug < Rampart::Domain::ValueObject
    attribute :value, Rampart::Types::String.constrained(min_size: 1, max_size: 100)

    def to_s
      value
    end

    def self.from(slug)
      new(value: slug.to_s)
    end

    def self.generate(name)
      slug_value = name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
      new(value: slug_value)
    end
  end
end

