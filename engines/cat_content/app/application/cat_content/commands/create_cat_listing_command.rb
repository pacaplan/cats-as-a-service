# frozen_string_literal: true

module CatContent
  module Commands
    class CreateCatListingCommand < Rampart::Application::Command
      attribute :name, Rampart::Types::String
      attribute :description, Rampart::Types::String
      attribute :price_cents, Rampart::Types::Integer
      attribute :currency, Rampart::Types::String.default("USD")
      attribute :slug, Rampart::Types::String
      attribute :tags, Rampart::Types::Array.of(Rampart::Types::String).default([].freeze)
      attribute :profile, Rampart::Types::Hash.optional.default(nil)
      attribute :media, Rampart::Types::Hash.optional.default(nil)
      attribute :publish, Rampart::Types::Bool.default(false)
    end
  end
end
