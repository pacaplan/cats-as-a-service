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
          name: record.name,
          email_verified: record.email_verified || false,
          status: record.status || "active",
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end
    end
  end
end


