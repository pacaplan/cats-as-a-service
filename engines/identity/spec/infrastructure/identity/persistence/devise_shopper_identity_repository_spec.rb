# frozen_string_literal: true

require "rails_helper"
require "securerandom"

RSpec.describe Identity::DeviseShopperIdentityRepository do
  let(:repo) { described_class.new }

  describe "#create" do
    it "normalizes email to lowercase" do
      email = "UPCASE-#{SecureRandom.hex(4)}@Example.com"

      result = repo.create(
        email: email,
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Test Shopper"
      )

      expect(result).to be_success
      domain = result.value!
      expect(domain.email).to eq(email.downcase)

      record = Identity::ShopperIdentityRecord.find_by(email: email.downcase)
      expect(record).not_to be_nil
    end

    it "returns Failure with validation errors when invalid" do
      email = "invalid-create-#{SecureRandom.hex(4)}@example.com"

      result = repo.create(
        email: email,
        password: "short",
        password_confirmation: "short",
        name: "Test Shopper"
      )

      expect(result).to be_failure
      expect(result.failure).to be_a(Hash)
    end
  end

  describe "#find_by_email" do
    it "returns nil when not found" do
      expect(repo.find_by_email("missing-#{SecureRandom.hex(4)}@example.com")).to be_nil
    end

    it "returns a domain aggregate when found (case-insensitive)" do
      email = "find-test-#{SecureRandom.hex(4)}@example.com"
      Identity::ShopperIdentityRecord.create!(
        email: email,
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Find Test"
      )

      domain = repo.find_by_email(email.upcase)

      expect(domain).to be_a(Identity::ShopperIdentity)
      expect(domain.email).to eq(email)
    end
  end

  describe "#authenticate" do
    it "returns Failure(:invalid_credentials) when email not found" do
      result = repo.authenticate(email: "missing-#{SecureRandom.hex(4)}@example.com", password: "whatever")

      expect(result).to be_failure
      expect(result.failure).to eq(:invalid_credentials)
    end

    it "returns Failure(:account_suspended) when record is suspended" do
      email = "suspended-#{SecureRandom.hex(4)}@example.com"
      record = Identity::ShopperIdentityRecord.create!(
        email: email,
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Suspended"
      )
      record.update!(status: "suspended")

      result = repo.authenticate(email: email, password: "securepassword123")

      expect(result).to be_failure
      expect(result.failure).to eq(:account_suspended)
    end

    it "returns Success and resets failed_attempts on valid password" do
      email = "signin-ok-#{SecureRandom.hex(4)}@example.com"
      record = Identity::ShopperIdentityRecord.create!(
        email: email,
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Sign In"
      )
      record.update!(failed_attempts: 2)

      result = repo.authenticate(email: email, password: "securepassword123")

      expect(result).to be_success
      expect(result.value!).to be_a(Identity::ShopperIdentity)
      expect(result.value!.email).to eq(email)

      record.reload
      expect(record.failed_attempts).to eq(0)
    end

    it "increments failed_attempts on invalid password" do
      email = "signin-bad-#{SecureRandom.hex(4)}@example.com"
      record = Identity::ShopperIdentityRecord.create!(
        email: email,
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Sign In"
      )

      initial_attempts = record.failed_attempts

      result = repo.authenticate(email: email, password: "wrongpassword123")

      expect(result).to be_failure

      record.reload
      expect(record.failed_attempts).to eq(initial_attempts + 1)
    end

    it "returns Failure(:account_locked) when access is locked" do
      email = "locked-#{SecureRandom.hex(4)}@example.com"
      record = Identity::ShopperIdentityRecord.create!(
        email: email,
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Locked"
      )

      # Avoid Devise's lock_access! which may depend on unlock_token columns that
      # are not present in this project's schema. Setting locked_at is sufficient
      # for access_locked? to return true.
      record.update!(failed_attempts: 5, locked_at: Time.current)
      expect(record.access_locked?).to eq(true)

      result = repo.authenticate(email: email, password: "securepassword123")

      expect(result).to be_failure
      expect(result.failure).to eq(:account_locked)
    end
  end
end
