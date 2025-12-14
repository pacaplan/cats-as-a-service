# frozen_string_literal: true

module CatContent
  module ValueObjects
    class ContentBlock < Rampart::Domain::ValueObject
      MAX_LENGTH = 5000

      attribute :text, Rampart::Types::String.constrained(max_size: MAX_LENGTH)

      def to_s = text
    end
  end
end

