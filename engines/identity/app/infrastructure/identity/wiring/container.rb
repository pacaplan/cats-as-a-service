# frozen_string_literal: true

require "dry-container"
require "dry-auto_inject"

module Identity
  # Dependency Injection container for the Identity bounded context
  class Container
    extend Dry::Container::Mixin

    # Repositories
    register(:shopper_identity_repo) { DeviseShopperIdentityRepository.new }

    # Services
    register(:shopper_auth_service) do
      ShopperAuthService.new(
        shopper_identity_repo: resolve(:shopper_identity_repo)
      )
    end
  end

  # Auto-inject module for dependency injection
  Import = Dry::AutoInject(Container)
end


