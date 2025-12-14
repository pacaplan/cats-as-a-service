# frozen_string_literal: true

module CatContent
  module ValueObjects
    class Money < Rampart::Domain::ValueObject
      attribute :amount_cents, Rampart::Types::Integer
      attribute :currency, Rampart::Types::String.default("USD")

      def formatted
        "$#{format('%.2f', amount_cents / 100.0)} #{currency}"
      end

      def +(other)
        raise ArgumentError, "Currency mismatch" unless currency == other.currency
        self.class.new(amount_cents: amount_cents + other.amount_cents, currency: currency)
      end
    end
  end
end

