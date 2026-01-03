# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Register shopper", type: :request do
  def parsed_body
    JSON.parse(response.body)
  end

  it "creates a shopper and establishes a session" do
    payload = {
      user: {
        email: "shopper@example.com",
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Jane Doe"
      }
    }

    post "/users", params: payload, as: :json

    expect(response).to have_http_status(:created)
    expect(parsed_body.fetch("email")).to eq("shopper@example.com")
    expect(parsed_body.fetch("name")).to eq("Jane Doe")
    expect(parsed_body.fetch("email_verified")).to eq(false)

    session_key = Rails.application.config.session_options[:key]
    expect(response.headers.fetch("Set-Cookie", "")).to include(session_key)

    record = Identity::ShopperIdentityRecord.find_by(email: "shopper@example.com")
    expect(record).not_to be_nil
  end

  it "returns validation errors when email is missing" do
    payload = {
      user: {
        email: nil,
        password: "securepassword123",
        password_confirmation: "securepassword123",
        name: "Jane Doe"
      }
    }

    post "/users", params: payload, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_body.fetch("errors")).to include("email")
  end
end
