# frozen_string_literal: true

module Identity
  # Port for ShopperIdentity persistence
  #
  # Implementations:
  # - DeviseShopperIdentityRepository (production)
  class ShopperIdentityRepository < Rampart::Ports::SecondaryPort
    abstract_method :create
    abstract_method :find_by_email
    abstract_method :authenticate
  end
end


