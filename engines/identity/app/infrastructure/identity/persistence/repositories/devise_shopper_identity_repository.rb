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
  end
end
