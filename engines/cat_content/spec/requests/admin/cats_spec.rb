# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Cats API", type: :request do
  let(:admin_id) { SecureRandom.uuid }
  # Assuming some mechanism to identify admin, e.g. checking user roles via ID
  let(:headers) { { "X-User-Id" => admin_id, "X-Admin" => "true" } }

  describe "GET /admin/cats" do
    subject(:make_request) { get "/admin/cats", params: params, headers: headers }

    let(:params) { {} }

    let!(:premade_cat) do
      create(:cat_listing_record, :published,
        name: "Premade Cat",
        slug: "premade-cat"
      )
    end

    let!(:custom_cat) do
      create(:custom_cat_record,
        name: "Custom Cat",
        user_id: SecureRandom.uuid,
        visibility: "private"
      )
    end

    context "as admin" do
      it "returns 200 OK" do
        make_request
        expect(response).to have_http_status(:ok)
      end

      it "returns all cats" do
        make_request
        json = response.parsed_body
        
        names = json["cats"].map { |c| c["name"] }
        expect(names).to include("Premade Cat", "Custom Cat")
      end

      context "with filters" do
        it "filters by type=premade" do
          get "/admin/cats", params: { type: "premade" }, headers: headers
          json = response.parsed_body
          names = json["cats"].map { |c| c["name"] }
          expect(names).to include("Premade Cat")
          expect(names).not_to include("Custom Cat")
        end

        it "filters by visibility=private" do
          get "/admin/cats", params: { visibility: "private" }, headers: headers
          json = response.parsed_body
          names = json["cats"].map { |c| c["name"] }
          expect(names).to include("Custom Cat")
          expect(names).not_to include("Premade Cat") # premade is published
        end
      end
    end

    context "as non-admin" do
      let(:headers) { { "X-User-Id" => SecureRandom.uuid } }

      it "returns 403 Forbidden" do
        make_request
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /admin/cats" do
    subject(:make_request) { post "/admin/cats", params: params, headers: headers }

    let(:params) do
      {
        name: "Whiskers McFluff",
        description: "A majestic cat",
        image_url: "https://example.com/cat.jpg",
        price_cents: 9999,
        currency: "USD",
        tags: ["fluffy"],
        slug: "whiskers-mcfluff"
      }
    end

    context "as admin" do
      it "creates a new premade cat" do
        expect { make_request }.to change(CatContent::CatListingRecord, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "returns the created cat" do
        make_request
        json = response.parsed_body
        expect(json["name"]).to eq("Whiskers McFluff")
        expect(json["type"]).to eq("premade") 
      end
    end

    context "as non-admin" do
      let(:headers) { { "X-User-Id" => SecureRandom.uuid } }

      it "returns 403 Forbidden" do
        make_request
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /admin/cats/:id" do
    subject(:make_request) { get "/admin/cats/#{id}", headers: headers }

    let(:premade_cat) { create(:cat_listing_record, name: "Premade") }
    let(:id) { premade_cat.id }

    context "as admin" do
      it "returns premade cat details" do
        make_request
        json = response.parsed_body
        expect(json["name"]).to eq("Premade")
      end

      context "finding a custom cat" do
        let(:custom_cat) { create(:custom_cat_record, name: "Custom") }
        let(:id) { custom_cat.id }

        it "returns custom cat details" do
          make_request
          json = response.parsed_body
          expect(json["name"]).to eq("Custom")
        end
      end
    end
  end

  describe "PUT /admin/cats/:id" do
    subject(:make_request) { put "/admin/cats/#{id}", params: params, headers: headers }

    let(:premade_cat) { create(:cat_listing_record, name: "Original Name") }
    let(:id) { premade_cat.id }
    let(:params) { { name: "Updated Name" } }

    context "as admin" do
      it "updates the premade cat" do
        make_request
        expect(response).to have_http_status(:ok)
        expect(premade_cat.reload.name).to eq("Updated Name")
      end

      context "attempting to update custom cat" do
        let(:custom_cat) { create(:custom_cat_record, name: "Custom") }
        let(:id) { custom_cat.id }

        it "returns error (forbidden or bad request)" do
          # Doc says "Custom cats cannot be edited by admin"
          make_request
          expect(response).not_to have_http_status(:ok)
        end
      end
    end
  end

  describe "PATCH /admin/cats/:id/publish" do
    subject(:make_request) { patch "/admin/cats/#{id}/publish", headers: headers }

    let(:premade_cat) { create(:cat_listing_record, visibility: "private") }
    let(:id) { premade_cat.id }

    context "as admin" do
      it "publishes the cat" do
        make_request
        expect(response).to have_http_status(:ok)
        
        json = response.parsed_body
        expect(json["visibility"]).to eq("public")
        expect(premade_cat.reload.visibility).to eq("public")
      end
    end
  end

  describe "PATCH /admin/cats/:id/archive" do
    subject(:make_request) { patch "/admin/cats/#{id}/archive", headers: headers }

    let(:premade_cat) { create(:cat_listing_record, visibility: "public") }
    let(:id) { premade_cat.id }

    context "as admin" do
      it "archives the cat" do
        make_request
        expect(response).to have_http_status(:ok)
        
        json = response.parsed_body
        expect(json["visibility"]).to eq("archived")
        expect(premade_cat.reload.visibility).to eq("archived")
      end
    end
  end
  
  describe "DELETE /admin/cats/:id" do
    subject(:make_request) { delete "/admin/cats/#{id}", headers: headers }
    
    let!(:premade_cat) { create(:cat_listing_record) }
    let(:id) { premade_cat.id }

    context "as admin" do
      it "archives or deletes the cat" do
        make_request
        # Depending on implementation, might return 204 or 200
        expect(response).to be_successful
        
        # Verify it's either gone or archived
        reloaded = CatContent::CatListingRecord.find_by(id: id)
        expect(reloaded.try(:visibility)).to eq("archived") if reloaded
      end
    end
  end
end
