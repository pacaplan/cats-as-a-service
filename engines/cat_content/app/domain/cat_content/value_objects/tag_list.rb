# frozen_string_literal: true

module CatContent
  # Collection of tags for a cat listing
  class TagList < Rampart::Domain::ValueObject
    attribute :values, Rampart::Types::Array.of(Rampart::Types::String).default([].freeze)

    def to_a
      values
    end

    def self.from(tags)
      tags_array = case tags
      when Array then tags.map(&:to_s)
      when String then tags.split(",").map(&:strip)
      else []
      end
      new(values: tags_array)
    end
  end
end

