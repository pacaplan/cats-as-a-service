 # frozen_string_literal: true

require "spec_helper"
require "dry/monads"

require "rampart"

unless defined?(Identity::ShopperIdentityRepository)
  require_relative "../../../app/domain/identity/ports/shopper_identity_repository"
end
require_relative "../../../app/application/identity/services/shopper_auth_service"

RSpec.describe Identity::ShopperAuthService do
  include Dry::Monads[:result]

  let(:shopper_identity_repo) { instance_double(Identity::ShopperIdentityRepository) }
  let(:service) { described_class.new(shopper_identity_repo: shopper_identity_repo) }

  describe "#register" do
    it "delegates to shopper_identity_repo.create" do
      allow(shopper_identity_repo).to receive(:create).and_return(Success(:shopper))

      result = service.register(
        email: "test@example.com",
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Jane Doe"
      )

      expect(shopper_identity_repo).to have_received(:create).with(
        email: "test@example.com",
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Jane Doe"
      )
      expect(result).to eq(Success(:shopper))
    end

    it "returns Failure with message when repository raises" do
      allow(shopper_identity_repo).to receive(:create).and_raise(StandardError, "boom")

      result = service.register(
        email: "test@example.com",
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Jane Doe"
      )

      expect(result).to eq(Failure("boom"))
    end
  end

  describe "#sign_in" do
    it "delegates to shopper_identity_repo.authenticate" do
      allow(shopper_identity_repo).to receive(:authenticate).and_return(Success(:shopper))

      result = service.sign_in(email: "test@example.com", password: "securepassword123")

      expect(shopper_identity_repo).to have_received(:authenticate).with(
        email: "test@example.com",
        password: "securepassword123"
      )
      expect(result).to eq(Success(:shopper))
    end

    it "returns Failure with message when repository raises" do
      allow(shopper_identity_repo).to receive(:authenticate).and_raise(StandardError, "boom")

      result = service.sign_in(email: "test@example.com", password: "securepassword123")

      expect(result).to eq(Failure("boom"))
    end
  end
end
