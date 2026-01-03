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
  # Lifecycle: active → suspended | locked (via failed attempts)
  class ShopperIdentity < Rampart::Domain::AggregateRoot
    # Lock duration in seconds (1 hour)
    LOCK_DURATION = 3600

    attribute :id, Rampart::Types::String
    attribute :email, Rampart::Types::String
    attribute :encrypted_password, Rampart::Types::String
    attribute :name, Rampart::Types::String
    attribute :provider, Rampart::Types::String.optional.default(nil)
    attribute :uid, Rampart::Types::String.optional.default(nil)
    attribute :email_verified, Rampart::Types::Bool.default(false)
    attribute :status, Rampart::Types::String.default("active")
    attribute :failed_attempts, Rampart::Types::Integer.default(0)
    attribute :locked_at, Rampart::Types::Time.optional.default(nil)
    attribute :created_at, Rampart::Types::Time.optional.default(nil)
    attribute :updated_at, Rampart::Types::Time.optional.default(nil)

    def active?
      status == "active"
    end

    def suspended?
      status == "suspended"
    end

    # Check if account is currently locked due to failed attempts
    # Account is locked if locked_at is set and within LOCK_DURATION
    def locked?
      return false if locked_at.nil?

      Time.current < locked_at + LOCK_DURATION
    end
  end
end
