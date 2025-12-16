# frozen_string_literal: true

module CatContent
  module Events
    class CustomCatArchived < Rampart::Domain::DomainEvent
      attribute :custom_cat_id, ValueObjects::CatId
      attribute :user_id, Types::String
    end
  end
end
