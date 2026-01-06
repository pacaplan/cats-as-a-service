# frozen_string_literal: true

module Identity
  # Port for AdminIdentity persistence
  #
  # Implementations:
  # - DeviseAdminIdentityRepository (production)
  class AdminIdentityRepository < Rampart::Ports::SecondaryPort
    abstract_method :create
    abstract_method :find_by_username
    abstract_method :authenticate
    abstract_method :username_exists?
  end
end
