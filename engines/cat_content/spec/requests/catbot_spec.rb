# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CatBot API", type: :request do
  let(:user_id) { SecureRandom.uuid }
  let(:headers) { { "X-User-Id" => user_id } }

  describe "POST /catbot/generate" do
    subject(:make_request) { post "/catbot/generate", params: params, headers: headers }

    let(:params) do
      {
        prompt_text: "A fluffy orange cat with chaotic energy",
        selected_name: "Sir Fluffington",
        quiz_results: { personality: "Chaotic Gremlin" }
      }
    end

    context "when authenticated" do
      it "returns 200 OK or 201 Created" do
        # Api doc example shows response but not status code. Assuming 200/201.
        # usually generate creates a resource -> 201
        make_request
        expect(response).to have_http_status(:success) 
      end

      it "returns the generated cat" do
        make_request
        json = response.parsed_body
        
        expect(json).to include(
          "name" => "Sir Fluffington",
          "visibility" => "private"
        )
        expect(json["id"]).to be_present
        expect(json["description"]).to be_present
        expect(json["image_url"]).to be_present
      end

      it "creates a new custom cat record" do
        expect { make_request }.to change(CatContent::CustomCatRecord, :count).by(1)
      end
    end

    context "when not authenticated" do
      let(:headers) { {} }

      it "returns 401 Unauthorized" do
        make_request
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /catbot/regenerate-description" do
    subject(:make_request) { post "/catbot/regenerate-description", params: params, headers: headers }

    let!(:cat) { create(:custom_cat_record, user_id: user_id) }
    let(:params) do
      {
        custom_cat_id: cat.id,
        modification_hint: "make it fluffier"
      }
    end

    context "when authenticated" do
      context "when cat belongs to user" do
        it "returns success" do
          make_request
          expect(response).to have_http_status(:success)
        end

        it "returns updated description" do
          make_request
          json = response.parsed_body
          expect(json["description"]).to be_present
          expect(json["regenerated_at"]).to be_present
        end
      end

      context "when cat belongs to another user" do
        let!(:cat) { create(:custom_cat_record, user_id: SecureRandom.uuid) }

        it "returns 404 Not Found" do
          make_request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when not authenticated" do
      let(:headers) { {} }

      it "returns 401 Unauthorized" do
        make_request
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /catbot/quiz" do
    subject(:make_request) { get "/catbot/quiz" }

    it "returns 200 OK" do
      make_request
      expect(response).to have_http_status(:ok)
    end

    it "returns quiz questions" do
      make_request
      json = response.parsed_body
      
      expect(json["questions"]).to be_an(Array)
      expect(json["questions"].first).to include("id", "text", "options")
    end
  end

  describe "POST /catbot/quiz/submit" do
    subject(:make_request) { post "/catbot/quiz/submit", params: params }

    let(:params) do
      {
        answers: {
          q1: "playful",
          q2: "void"
        }
      }
    end

    it "returns 200 OK" do
      make_request
      expect(response).to have_http_status(:ok)
    end

    it "returns personality result" do
      make_request
      json = response.parsed_body
      
      expect(json).to include(
        "personality",
        "description",
        "shareable_text"
      )
    end
  end
end
