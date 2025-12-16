# frozen_string_literal: true

module CatContent
  module Events
    class CustomCatCreated < Rampart::Domain::DomainEvent
      attribute :custom_cat_id, ValueObjects::CatId
      attribute :user_id, Types::String
      attribute :name, Types::String
    end
  end
end
