# frozen_string_literal: true

require "dry/monads"

module Identity
  # Devise implementation of AdminIdentityRepository
  class DeviseAdminIdentityRepository < AdminIdentityRepository
    include Dry::Monads[:result]

    # Create a new admin identity
    #
    # @param username [String]
    # @param password [String]
    # @return [Result<AdminIdentity>]
    def create(username:, password:)
      normalized_username = username.to_s.strip.downcase

      record = AdminIdentityRecord.new(
        username: normalized_username,
        password: password,
        password_confirmation: password
      )

      if record.save
        Success(AdminIdentityMapper.to_domain(record))
      else
        Failure(record.errors.messages)
      end
    end

    # Find an admin identity by username
    #
    # @param username [String]
    # @return [AdminIdentity, nil]
    def find_by_username(username)
      record = AdminIdentityRecord.find_by("LOWER(username) = ?", username.to_s.downcase)
      AdminIdentityMapper.to_domain(record)
    end

    # Check if username already exists
    #
    # @param username [String]
    # @return [Boolean]
    def username_exists?(username)
      AdminIdentityRecord.exists?(["LOWER(username) = ?", username.to_s.downcase])
    end

    # Authenticate an admin by username and password
    #
    # @param username [String]
    # @param password [String]
    # @return [Result<AdminIdentity>]
    #   Success with AdminIdentity on valid credentials
    #   Failure with :invalid_credentials or :account_locked
    def authenticate(username:, password:)
      normalized_username = username.to_s.strip.downcase
      record = AdminIdentityRecord.find_by("LOWER(username) = ?", normalized_username)

      # Username not found - return generic error (security: don't reveal if username exists)
      return Failure(:invalid_credentials) if record.nil?

      # Check if account is locked (Devise lockable)
      if record.access_locked?
        return Failure(:account_locked)
      end

      # Verify password using Devise's method
      if record.valid_password?(password)
        # Success: reset failed attempts and return domain entity
        record.update(failed_attempts: 0) if record.failed_attempts > 0
        Success(AdminIdentityMapper.to_domain(record))
      else
        # Failure: increment failed attempts, potentially lock
        record.increment_failed_attempts

        # Re-check if the increment caused a lock (reload to get fresh state)
        if record.reload.access_locked?
          Failure(:account_locked)
        else
          Failure(:invalid_credentials)
        end
      end
    end
  end
end
