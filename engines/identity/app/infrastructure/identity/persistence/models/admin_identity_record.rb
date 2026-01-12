# frozen_string_literal: true

module Identity
  # ActiveRecord model for admin_identities table
  class AdminIdentityRecord < Identity::BaseRecord
    self.table_name = "identity.admin_identities"

    # Devise modules
    # - database_authenticatable: password hashing and verification
    # - lockable: account locking after failed attempts
    # - timeoutable: session expiry after inactivity (30 min for admins)
    # Note: NOT registerable (admins created via rake task only)
    devise :database_authenticatable, :lockable, :timeoutable

    # Use username instead of email for authentication
    devise_modules.delete(:validatable) # Don't validate email
    def self.authentication_keys
      [:username]
    end

    def email_required?
      false
    end

    # Validations
    validates :username, presence: true, length: {maximum: 100}, uniqueness: {case_sensitive: false}
    validates :status, presence: true, inclusion: {in: %w[active locked]}

    # Override Devise's authentication key (use username instead of email)
    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      username = conditions.delete(:username)&.downcase
      where(conditions.to_h).find_by("LOWER(username) = ?", username)
    end

    # Override timeout_in for 30-minute admin sessions (different from shoppers' 24 hours)
    def timeout_in
      30.minutes
    end
  end
end
