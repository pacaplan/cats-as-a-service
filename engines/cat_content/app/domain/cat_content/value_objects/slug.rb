# frozen_string_literal: true

module CatContent
  module ValueObjects
    class Slug < Rampart::Domain::ValueObject
      VALID_SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
      MAX_LENGTH = 100

      attribute :value, Rampart::Types::String.constrained(
        format: VALID_SLUG_PATTERN,
        max_size: MAX_LENGTH
      )

      def self.generate_from(name)
        normalized = name
          .downcase
          .gsub(/[^a-z0-9\s-]/, "")
          .gsub(/\s+/, "-")
          .gsub(/-+/, "-")
          .gsub(/\A-|-\z/, "")
          .slice(0, MAX_LENGTH)

        new(value: normalized)
      end

      def to_s = value
    end
  end
end

