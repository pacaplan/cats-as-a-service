# frozen_string_literal: true

module Identity
  # Application service for ShopperIdentity operations
  #
  # Orchestrates domain logic for shopper authentication.
  class ShopperAuthService < Rampart::Application::Service
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
      if password != password_confirmation
        return Failure("Password confirmation doesn't match Password")
      end

      shopper_identity = @shopper_identity_repo.create(
        email: email,
        password: password,
        name: name
      )

      Success(shopper_identity)
    rescue StandardError => e
      Failure(e)
    end
  end
end


