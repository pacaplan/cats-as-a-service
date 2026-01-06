# frozen_string_literal: true

require "dry-container"
require "dry-auto_inject"

module Identity
  # Dependency Injection container for the Identity bounded context
  class Container
    extend Dry::Container::Mixin

    # Repositories
    register(:shopper_identity_repo) { DeviseShopperIdentityRepository.new }
    register(:admin_identity_repo) { DeviseAdminIdentityRepository.new }

    # Services
    register(:shopper_auth_service) do
      ShopperAuthService.new(
        shopper_identity_repo: resolve(:shopper_identity_repo)
      )
    end
    register(:admin_auth_service) do
      AdminAuthService.new(
        admin_identity_repo: resolve(:admin_identity_repo)
      )
    end
  end

  # Auto-inject module for dependency injection
  Import = Dry::AutoInject(Container)
end
