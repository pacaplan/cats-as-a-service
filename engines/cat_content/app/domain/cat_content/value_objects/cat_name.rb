# frozen_string_literal: true

module CatContent
  module ValueObjects
    class CatName < Rampart::Domain::ValueObject
      MAX_LENGTH = 100
      MIN_LENGTH = 1

      attribute :value, Rampart::Types::String.constrained(
        min_size: MIN_LENGTH,
        max_size: MAX_LENGTH
      )

      def to_s = value
    end
  end
end

