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
      result = @shopper_identity_repo.create(
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        name: name
      )

      result
    rescue StandardError => e
      Failure(e.message)
    end
  end
end


