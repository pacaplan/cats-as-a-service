# frozen_string_literal: true

module Identity
  # ShopperIdentity Aggregate Root
  #
  # Authentication record for a shopper; supports password and Google OAuth.
  #
  # Invariants:
  # - email must be present and valid format
  # - password must meet minimum strength requirements (12+ chars)
  # - Google-linked identity requires provider='google_oauth2' and uid
  #
  # Lifecycle: active → suspended
  class ShopperIdentity < Rampart::Domain::AggregateRoot
    attribute :id, Rampart::Types::String
    attribute :email, Rampart::Types::String
    attribute :name, Rampart::Types::String
    attribute :email_verified, Rampart::Types::Bool.default(false)
    attribute :status, Rampart::Types::String.default("active")
    attribute :created_at, Rampart::Types::Time.optional.default(nil)
    attribute :updated_at, Rampart::Types::Time.optional.default(nil)

    def active?
      status == "active"
    end

    def suspended?
      status == "suspended"
    end
  end
end


