# frozen_string_literal: true

module Identity
  # AdminIdentity Aggregate Root
  #
  # Authentication record for an admin user; supports username/password only.
  #
  # Invariants:
  # - username must be present and unique
  # - password must meet minimum strength requirements (24+ chars for provisioned admins)
  # - can only be created via server-side script (rake task)
  #
  # Lifecycle: active -> locked (via failed attempts, 1 hour lockout)
  class AdminIdentity < Rampart::Domain::AggregateRoot
    # Lock duration in seconds (1 hour)
    LOCK_DURATION = 3600

    # Session timeout in seconds (30 minutes)
    SESSION_TIMEOUT = 1800

    # Maximum failed attempts before lock
    MAX_FAILED_ATTEMPTS = 5

    attribute :id, Rampart::Types::String
    attribute :username, Rampart::Types::String
    attribute :encrypted_password, Rampart::Types::String
    attribute :status, Rampart::Types::String.default("active")
    attribute :failed_attempts, Rampart::Types::Integer.default(0)
    attribute :locked_at, Rampart::Types::Time.optional.default(nil)
    attribute :created_at, Rampart::Types::Time.optional.default(nil)
    attribute :updated_at, Rampart::Types::Time.optional.default(nil)

    # Check if account is currently locked due to failed attempts
    # Account is locked if locked_at is set and within LOCK_DURATION
    def locked?
      return false if locked_at.nil?

      Time.current < locked_at + LOCK_DURATION
    end
  end
end
