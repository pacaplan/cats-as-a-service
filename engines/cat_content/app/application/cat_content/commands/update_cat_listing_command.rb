# frozen_string_literal: true

module CatContent
  module Commands
    class UpdateCatListingCommand < Rampart::Application::Command
      attribute :name, Rampart::Types::String.optional.default(nil)
      attribute :description, Rampart::Types::String.optional.default(nil)
      attribute :price_cents, Rampart::Types::Integer.optional.default(nil)
      attribute :tags, Rampart::Types::Array.of(Rampart::Types::String).optional.default(nil)
      attribute :profile, Rampart::Types::Hash.optional.default(nil)
      attribute :media, Rampart::Types::Hash.optional.default(nil)
    end
  end
end
