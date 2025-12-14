# frozen_string_literal: true

module CatContent
  module ValueObjects
    class TraitSet < Rampart::Domain::ValueObject
      # Allow any string traits for flexibility
      attribute :values, Rampart::Types::Array.of(Rampart::Types::String)

      def include?(trait)
        values.include?(trait.to_s)
      end

      def to_a = values
    end
  end
end

