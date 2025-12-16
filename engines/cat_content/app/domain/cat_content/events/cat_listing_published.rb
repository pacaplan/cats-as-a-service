# frozen_string_literal: true

module CatContent
  module Events
    class CatListingPublished < Rampart::Domain::DomainEvent
      attribute :cat_id, ValueObjects::CatId
      attribute :slug, Types::String.optional
    end
  end
end
