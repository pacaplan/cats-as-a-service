# frozen_string_literal: true

require "dry/monads"

module Identity
  # Devise implementation of ShopperIdentityRepository
  class DeviseShopperIdentityRepository < ShopperIdentityRepository
    include Dry::Monads[:result]

    # Create a new shopper identity
    #
    # @param email [String]
    # @param password [String]
    # @param password_confirmation [String]
    # @param name [String]
    # @return [Result<ShopperIdentity>]
    def create(email:, password:, password_confirmation:, name:)
      # Normalize email to lowercase for case-insensitive lookup
      normalized_email = email.to_s.strip.downcase

      record = ShopperIdentityRecord.new(
        email: normalized_email,
        password: password,
        password_confirmation: password_confirmation,
        name: name
      )

      if record.save
        Success(ShopperIdentityMapper.to_domain(record))
      else
        Failure(record.errors.messages)
      end
    end

    # Find a shopper identity by email
    #
    # @param email [String]
    # @return [ShopperIdentity, nil]
    def find_by_email(email)
      record = ShopperIdentityRecord.find_by(email: email.downcase)
      ShopperIdentityMapper.to_domain(record)
    end

    # Authenticate a shopper by email and password
    #
    # @param email [String]
    # @param password [String]
    # @return [Result<ShopperIdentity>]
    #   Success with ShopperIdentity on valid credentials
    #   Failure with :invalid_credentials, :account_suspended, or :account_locked
    def authenticate(email:, password:)
      normalized_email = email.to_s.strip.downcase
      record = ShopperIdentityRecord.find_by(email: normalized_email)

      # Email not found - return generic error (security: don't reveal if email exists)
      return Failure(:invalid_credentials) if record.nil?

      # Check if account is locked (Devise lockable)
      if record.access_locked?
        return Failure(:account_locked)
      end

      # Check if account is suspended (business status)
      if record.status == "suspended"
        return Failure(:account_suspended)
      end

      # Verify password using Devise's method
      if record.valid_password?(password)
        # Success: reset failed attempts and return domain entity
        record.update(failed_attempts: 0) if record.failed_attempts > 0
        Success(ShopperIdentityMapper.to_domain(record))
      else
        # Failure: increment failed attempts, potentially lock
        record.increment_failed_attempts

        # Re-check if the increment caused a lock
        if record.access_locked?
          Failure(:account_locked)
        else
          Failure(:invalid_credentials)
        end
      end
    end
  end
end
