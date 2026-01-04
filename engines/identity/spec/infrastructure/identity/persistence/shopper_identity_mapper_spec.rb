# frozen_string_literal: true

require "rails_helper"
require "securerandom"

RSpec.describe Identity::ShopperIdentityMapper do
  describe ".to_domain" do
    it "returns nil when record is nil" do
      expect(described_class.to_domain(nil)).to be_nil
    end

    it "maps an ActiveRecord record to a domain aggregate" do
      record = Identity::ShopperIdentityRecord.create!(
        email: "mapper-test-#{SecureRandom.hex(4)}@example.com",
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Mapper Test"
      )

      domain = described_class.to_domain(record)

      expect(domain).to be_a(Identity::ShopperIdentity)
      expect(domain.id).to eq(record.id.to_s)
      expect(domain.email).to eq(record.email)
      expect(domain.name).to eq(record.name)
      expect(domain.email_verified).to eq(false)
      expect(domain.status).to eq("active")
      expect(domain.failed_attempts).to eq(0)
      expect(domain.locked_at).to eq(record.locked_at)
      expect(domain.created_at).to eq(record.created_at)
      expect(domain.updated_at).to eq(record.updated_at)
      expect(domain.encrypted_password).to eq(record.encrypted_password)
    end
  end
end
