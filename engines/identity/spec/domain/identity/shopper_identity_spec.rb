# frozen_string_literal: true

require "spec_helper"
require "securerandom"

unless defined?(Identity::ShopperIdentity)
  require_relative "../../../app/domain/identity/aggregates/shopper_identity"
end

RSpec.describe Identity::ShopperIdentity do
  before do
    unless Time.respond_to?(:current)
      Time.define_singleton_method(:current) { Time.now }
    end
  end

  describe "predicate helpers" do
    it "is active when status is active" do
      identity = described_class.new(
        id: SecureRandom.uuid,
        email: "test-#{SecureRandom.hex(4)}@example.com",
        encrypted_password: "encrypted",
        name: "Test",
        status: "active"
      )

      expect(identity.active?).to eq(true)
      expect(identity.suspended?).to eq(false)
    end

    it "is suspended when status is suspended" do
      identity = described_class.new(
        id: SecureRandom.uuid,
        email: "test-#{SecureRandom.hex(4)}@example.com",
        encrypted_password: "encrypted",
        name: "Test",
        status: "suspended"
      )

      expect(identity.active?).to eq(false)
      expect(identity.suspended?).to eq(true)
    end
  end

  describe "#locked?" do
    it "is not locked when locked_at is nil" do
      identity = described_class.new(
        id: SecureRandom.uuid,
        email: "test-#{SecureRandom.hex(4)}@example.com",
        encrypted_password: "encrypted",
        name: "Test",
        locked_at: nil
      )

      expect(identity.locked?).to eq(false)
    end

    it "is locked when locked_at is within LOCK_DURATION" do
      locked_at = Time.now
      identity = described_class.new(
        id: SecureRandom.uuid,
        email: "test-#{SecureRandom.hex(4)}@example.com",
        encrypted_password: "encrypted",
        name: "Test",
        locked_at: locked_at
      )

      allow(Time).to receive(:current).and_return(locked_at + (described_class::LOCK_DURATION - 1))
      expect(identity.locked?).to eq(true)
    end

    it "is not locked when lock duration has passed" do
      locked_at = Time.now
      identity = described_class.new(
        id: SecureRandom.uuid,
        email: "test-#{SecureRandom.hex(4)}@example.com",
        encrypted_password: "encrypted",
        name: "Test",
        locked_at: locked_at
      )

      allow(Time).to receive(:current).and_return(locked_at + described_class::LOCK_DURATION + 1)
      expect(identity.locked?).to eq(false)
    end
  end
end
