# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Custom Cats API", type: :request do
  let(:user_id) { SecureRandom.uuid }
  # Assuming authentication is handled via header or similar mechanism provided by the main app
  let(:headers) { { "X-User-Id" => user_id } }

  describe "GET /custom-cats" do
    subject(:make_request) { get "/custom-cats", params: params, headers: headers }

    let(:params) { {} }

    context "when authenticated" do
      context "when user has custom cats" do
        let!(:my_cat) do
          create(:custom_cat_record,
            name: "Lord Fluffington III",
            description: "An AI-generated noble",
            image_url: "https://example.com/lord.jpg",
            visibility: "private",
            user_id: user_id,
            created_at: 1.day.ago
          )
        end

        let!(:other_cat) do
          create(:custom_cat_record,
            name: "Stranger Cat",
            user_id: SecureRandom.uuid
          )
        end

        let!(:archived_cat) do
          create(:custom_cat_record, :archived,
            name: "Old Cat",
            user_id: user_id
          )
        end

        it "returns 200 OK" do
          make_request
          expect(response).to have_http_status(:ok)
        end

        it "returns only non-archived cats belonging to the user" do
          make_request
          json = response.parsed_body
          
          expect(json["custom_cats"].size).to eq(1)
          expect(json["custom_cats"].first["id"]).to eq(my_cat.id)
          expect(json["custom_cats"].first["name"]).to eq("Lord Fluffington III")
        end

        context "with include_archived parameter" do
          let(:params) { { include_archived: true } }

          it "includes archived cats" do
            make_request
            json = response.parsed_body
            
            expect(json["custom_cats"].size).to eq(2)
            ids = json["custom_cats"].map { |c| c["id"] }
            expect(ids).to include(my_cat.id, archived_cat.id)
          end
        end
      end

      context "when user has no cats" do
        it "returns empty array" do
          make_request
          json = response.parsed_body
          expect(json["custom_cats"]).to eq([])
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

  describe "GET /custom-cats/:id" do
    subject(:make_request) { get "/custom-cats/#{id}", headers: headers }

    let(:id) { cat.id }
    let(:cat) do
      create(:custom_cat_record,
        name: "My Cat",
        user_id: user_id,
        prompt: {
          "text" => "A regal cat",
          "quiz_results" => { "personality" => "Chaotic Gremlin" }
        },
        story: "Once upon a time..."
      )
    end

    context "when authenticated" do
      context "when the cat exists and belongs to user" do
        it "returns 200 OK" do
          make_request
          expect(response).to have_http_status(:ok)
        end

        it "returns full cat details" do
          make_request
          json = response.parsed_body

          expect(json).to include(
            "id" => cat.id,
            "name" => "My Cat",
            "story" => "Once upon a time..."
          )
          
          expect(json["prompt"]).to include(
            "text" => "A regal cat"
          )
        end
      end

      context "when the cat belongs to another user" do
        let(:cat) { create(:custom_cat_record, user_id: SecureRandom.uuid) }

        it "returns 404 Not Found" do
          make_request
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the cat does not exist" do
        let(:id) { "non-existent" }

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

  describe "DELETE /custom-cats/:id" do
    subject(:make_request) { delete "/custom-cats/#{id}", headers: headers }

    let(:id) { cat.id }
    let!(:cat) { create(:custom_cat_record, user_id: user_id) }

    context "when authenticated" do
      context "when the cat exists and belongs to user" do
        it "returns 204 No Content" do
          make_request
          expect(response).to have_http_status(:no_content)
        end

        it "archives the cat" do
          make_request
          expect(cat.reload.visibility).to eq("archived")
        end
      end

      context "when the cat belongs to another user" do
        let!(:cat) { create(:custom_cat_record, user_id: SecureRandom.uuid) }

        it "returns 404 Not Found" do
          make_request
          expect(response).to have_http_status(:not_found)
        end

        it "does not change the cat status" do
          make_request
          expect(cat.reload.visibility).not_to eq("archived")
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
end
