# frozen_string_literal: true

module Identity
  # Devise implementation of ShopperIdentityRepository
  class DeviseShopperIdentityRepository < ShopperIdentityRepository
    # Create a new shopper identity
    #
    # @param email [String]
    # @param password [String]
    # @param name [String]
    # @return [ShopperIdentity]
    def create(email:, password:, name:)
      record = ShopperIdentityRecord.create!(
        email: email,
        password: password,
        name: name
      )

      ShopperIdentityMapper.to_domain(record)
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


