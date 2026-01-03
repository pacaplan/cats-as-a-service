# frozen_string_literal: true

module CatContent
  # Money value object with cents and currency
  class Money < Rampart::Domain::ValueObject
    attribute :cents, Rampart::Types::Integer.constrained(gteq: 1)
    attribute :currency, Rampart::Types::String.default("USD")

    def formatted
      dollars = cents / 100.0
      "$#{format("%.2f", dollars)}"
    end

    def to_h
      {
        cents: cents,
        currency: currency,
        formatted: formatted
      }
    end

    def self.from_cents(cents, currency: "USD")
      new(cents: cents.to_i, currency: currency)
    end
  end
end

