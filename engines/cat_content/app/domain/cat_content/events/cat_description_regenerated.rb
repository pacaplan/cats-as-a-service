# frozen_string_literal: true

module CatContent
  module Events
    class CatDescriptionRegenerated < Rampart::Domain::DomainEvent
      attribute :cat_id, ValueObjects::CatId
      attribute :description_text, Types::String
    end
  end
end
