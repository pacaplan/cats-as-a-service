# frozen_string_literal: true

module CatContent
  module ValueObjects
    class TagList < Rampart::Domain::ValueObject
      attribute :values, Rampart::Types::Array.of(Rampart::Types::String)

      def include?(tag)
        values.include?(tag)
      end

      def to_a = values
    end
  end
end

