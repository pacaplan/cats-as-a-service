# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign in shopper", type: :request do
  def parsed_body
    JSON.parse(response.body)
  end

  # Create a test shopper before each test
  let!(:shopper) do
    Identity::ShopperIdentityRecord.create!(
      email: "signin-test-#{SecureRandom.hex(4)}@example.com",
      password: "securepassword123",
      password_confirmation: "securepassword123",
      name: "Test Shopper"
    )
  end

  describe "POST /users/sign_in" do
    context "with valid credentials" do
      it "authenticates the shopper and returns user data" do
        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "securepassword123"}
        }, as: :json

        expect(response).to have_http_status(:ok)
        expect(parsed_body["id"]).to eq(shopper.id)
        expect(parsed_body["email"]).to eq(shopper.email)
        expect(parsed_body["name"]).to eq("Test Shopper")
        expect(parsed_body["email_verified"]).to eq(false)
        expect(parsed_body).to have_key("created_at")
      end

      it "establishes a session cookie" do
        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "securepassword123"}
        }, as: :json

        session_key = Rails.application.config.session_options[:key]
        expect(response.headers.fetch("Set-Cookie", "")).to include(session_key)
      end

      it "resets failed_attempts counter on successful login" do
        # First increment failed attempts
        shopper.update!(failed_attempts: 3)

        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "securepassword123"}
        }, as: :json

        expect(response).to have_http_status(:ok)
        shopper.reload
        expect(shopper.failed_attempts).to eq(0)
      end
    end

    context "with invalid credentials" do
      it "returns 401 with generic error for wrong password" do
        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "wrongpassword123"}
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body["error"]).to eq("Invalid email or password")
      end

      it "returns 401 with generic error for non-existent email" do
        post "/users/sign_in", params: {
          user: {email: "nonexistent@example.com", password: "somepassword123"}
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body["error"]).to eq("Invalid email or password")
      end

      it "returns 401 when email is missing" do
        post "/users/sign_in", params: {
          user: {email: "", password: "somepassword123"}
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body["error"]).to eq("Invalid email or password")
      end

      it "returns 401 when password is missing" do
        post "/users/sign_in", params: {
          user: {email: shopper.email, password: ""}
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body["error"]).to eq("Invalid email or password")
      end

      it "increments failed_attempts on failed login" do
        initial_attempts = shopper.failed_attempts

        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "wrongpassword123"}
        }, as: :json

        shopper.reload
        expect(shopper.failed_attempts).to eq(initial_attempts + 1)
      end
    end

    context "when account is suspended" do
      before { shopper.update!(status: "suspended") }

      it "returns 401 with suspended message" do
        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "securepassword123"}
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body["error"]).to eq("Your account has been suspended")
      end
    end

    context "when account is locked" do
      before do
        shopper.update!(
          failed_attempts: 5,
          locked_at: Time.current
        )
      end

      it "returns 401 with locked message" do
        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "securepassword123"}
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body["error"]).to include("locked")
        expect(parsed_body["error"]).to include("too many failed attempts")
      end
    end
  end

  describe "DELETE /users/sign_out" do
    it "signs out the shopper and clears the session" do
      # First sign in
      post "/users/sign_in", params: {
        user: {email: shopper.email, password: "securepassword123"}
      }, as: :json
      expect(response).to have_http_status(:ok)

      # Then sign out
      delete "/users/sign_out", as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["message"]).to eq("Signed out successfully")
    end
  end

  describe "GET /users/current" do
    context "when authenticated" do
      before do
        post "/users/sign_in", params: {
          user: {email: shopper.email, password: "securepassword123"}
        }, as: :json
      end

      it "returns the current user data" do
        get "/users/current", as: :json

        expect(response).to have_http_status(:ok)
        expect(parsed_body["id"]).to eq(shopper.id)
        expect(parsed_body["email"]).to eq(shopper.email)
        expect(parsed_body["name"]).to eq("Test Shopper")
      end
    end

    context "when not authenticated" do
      it "returns 401 unauthorized" do
        get "/users/current", as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body["error"]).to eq("Not authenticated")
      end
    end
  end
end
