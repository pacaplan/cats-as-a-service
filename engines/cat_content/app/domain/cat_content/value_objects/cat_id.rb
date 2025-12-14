# frozen_string_literal: true

module CatContent
  module ValueObjects
    class CatId < Rampart::Domain::ValueObject
      attribute :value, Rampart::Types::String

      def to_s = value

      def ==(other)
        other.is_a?(CatId) && other.value == value
      end
    end
  end
end

