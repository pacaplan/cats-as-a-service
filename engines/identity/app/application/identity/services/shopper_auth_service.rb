# frozen_string_literal: true

require "dry/monads"

module Identity
  # Application service for ShopperIdentity operations
  #
  # Orchestrates domain logic for shopper authentication.
  class ShopperAuthService < Rampart::Application::Service
    include Dry::Monads[:result]

    def initialize(shopper_identity_repo:)
      @shopper_identity_repo = shopper_identity_repo
    end

    # Register a new shopper
    #
    # @param email [String]
    # @param password [String]
    # @param password_confirmation [String]
    # @param name [String]
    # @return [Result<ShopperIdentity>]
    def register(email:, password:, password_confirmation:, name:)
      # Delegate validation to repository/Devise
      @shopper_identity_repo.create(
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        name: name
      )
    rescue => e
      Failure(e.message)
    end

    # Authenticate a shopper
    #
    # @param email [String]
    # @param password [String]
    # @return [Result<ShopperIdentity>]
    #   Success with ShopperIdentity on valid credentials
    #   Failure with :invalid_credentials, :account_suspended, or :account_locked
    def sign_in(email:, password:)
      @shopper_identity_repo.authenticate(email: email, password: password)
    rescue => e
      Failure(e.message)
    end
  end
end
