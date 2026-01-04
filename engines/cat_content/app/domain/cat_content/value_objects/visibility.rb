# frozen_string_literal: true

module CatContent
  # Visibility state for a cat listing (lifecycle state)
  class Visibility < Rampart::Domain::ValueObject
    PRIVATE = "private"
    PUBLISHED = "published"
    ARCHIVED = "archived"

    VALID_VALUES = [PRIVATE, PUBLISHED, ARCHIVED].freeze

    attribute :value, Rampart::Types::String.constrained(included_in: VALID_VALUES)

    def to_s
      value
    end

    def private?
      value == PRIVATE
    end

    def published?
      value == PUBLISHED
    end

    def archived?
      value == ARCHIVED
    end

    def self.private
      new(value: PRIVATE)
    end

    def self.published
      new(value: PUBLISHED)
    end

    def self.archived
      new(value: ARCHIVED)
    end

    def self.from(value)
      new(value: value.to_s)
    end
  end
end
