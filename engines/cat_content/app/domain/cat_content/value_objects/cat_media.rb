# frozen_string_literal: true

module CatContent
  module ValueObjects
    class CatMedia < Rampart::Domain::ValueObject
      attribute :url, Rampart::Types::String
      attribute :alt_text, Rampart::Types::String.optional.default(nil)
      attribute :content_type, Rampart::Types::String.optional.default(nil)
    end
  end
end

