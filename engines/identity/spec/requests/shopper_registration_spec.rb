# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Shopper Registration", type: :request do
  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          email: "test-#{SecureRandom.hex(4)}@example.com",
          password: "securepassword123",
          password_confirmation: "securepassword123",
          name: "Jane Doe"
        }
      }
    end

    it "creates a shopper with valid params" do
      post "/users", params: valid_params

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["email"]).to eq(valid_params.dig(:user, :email))
      expect(json_response["name"]).to eq("Jane Doe")
    end

    it "returns errors with invalid params" do
      post "/users", params: {user: {email: ""}}

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
  end
end
