# frozen_string_literal: true

module Identity
  # ActiveRecord model for shopper_identities table
  class ShopperIdentityRecord < Identity::BaseRecord
    self.table_name = "identity.shopper_identities"

    # Devise modules
    devise :database_authenticatable, :registerable, :validatable

    # Validations
    validates :name, presence: true, length: { maximum: 100 }
    validates :email, uniqueness: { case_sensitive: false }
    validates :status, presence: true, inclusion: { in: %w[active suspended] }
  end
end

