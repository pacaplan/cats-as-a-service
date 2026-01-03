# frozen_string_literal: true

module Identity
  # Maps between ShopperIdentityRecord (ActiveRecord) and ShopperIdentity (Domain)
  class ShopperIdentityMapper
    class << self
      # Convert ActiveRecord record to domain aggregate
      #
      # @param record [ShopperIdentityRecord]
      # @return [ShopperIdentity, nil]
      def to_domain(record)
        return nil if record.nil?

        ShopperIdentity.new(
          id: record.id.to_s,
          email: record.email,
          encrypted_password: record.encrypted_password,
          name: record.name,
          provider: record.provider,
          uid: record.uid,
          email_verified: record.email_verified || false,
          status: record.status || "active",
          failed_attempts: record.failed_attempts || 0,
          locked_at: record.locked_at,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end
    end
  end
end
