# frozen_string_literal: true

module CatContent
  module ValueObjects
    # CatProfile represents the cat's characteristics.
    # It's a value object because it doesn't have independent identity -
    # it's always part of a CatListing aggregate.
    class CatProfile < Rampart::Domain::ValueObject
      attribute :age_months, Rampart::Types::Integer.optional
      attribute :traits, TraitSet
      attribute :temperament, Rampart::Types::String.optional

      def adult?
        age_months && age_months >= 12
      end

      def kitten?
        age_months && age_months < 12
      end
    end
  end
end

