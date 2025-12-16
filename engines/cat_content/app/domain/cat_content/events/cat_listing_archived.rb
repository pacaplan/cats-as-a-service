# frozen_string_literal: true

module CatContent
  module Events
    class CatListingArchived < Rampart::Domain::DomainEvent
      attribute :cat_id, ValueObjects::CatId
    end
  end
end
