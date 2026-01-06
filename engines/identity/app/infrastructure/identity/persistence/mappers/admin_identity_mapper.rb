# frozen_string_literal: true

module Identity
  # Maps between AdminIdentityRecord (ActiveRecord) and AdminIdentity (Domain)
  class AdminIdentityMapper
    class << self
      # Convert ActiveRecord record to domain aggregate
      #
      # @param record [AdminIdentityRecord]
      # @return [AdminIdentity, nil]
      def to_domain(record)
        return nil if record.nil?

        AdminIdentity.new(
          id: record.id.to_s,
          username: record.username,
          encrypted_password: record.encrypted_password,
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
