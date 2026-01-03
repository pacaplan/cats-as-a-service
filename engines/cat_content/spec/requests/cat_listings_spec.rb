# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cat Listings API", type: :request do
  describe "GET /catalog" do
    context "when published listings exist" do
      before do
        # Use unique slugs to avoid conflicts with seeded data
        create(:cat_listing_record, :published,
          name: "Test Cat Alpha",
          slug: "test-cat-alpha-#{SecureRandom.hex(4)}",
          description: "A test cat",
          price_cents: 4800,
          tags: ["cozy", "cosmic"])
        create(:cat_listing_record, :published,
          name: "Test Cat Beta",
          slug: "test-cat-beta-#{SecureRandom.hex(4)}",
          description: "Another test cat",
          price_cents: 3900,
          tags: ["chaotic"])
        create(:cat_listing_record, :draft,
          name: "Draft Cat",
          slug: "draft-cat-#{SecureRandom.hex(4)}")
      end

      it "returns 200 OK" do
        get "/catalog"
        expect(response).to have_http_status(:ok)
      end

      it "returns published listings including seeded data" do
        get "/catalog"
        json = JSON.parse(response.body)
        # Should include our test cats plus seeded data
        expect(json["listings"].size).to be >= 2
        expect(json["count"]).to be >= 2
      end

      it "returns correctly formatted listings" do
        get "/catalog"
        json = JSON.parse(response.body)
        listing = json["listings"].find { |l| l["name"].start_with?("Test Cat Alpha") }

        expect(listing).to be_present
        expect(listing["id"]).to be_present
        expect(listing["slug"]).to be_present
        expect(listing["description"]).to eq("A test cat")
        expect(listing["price"]["cents"]).to eq(4800)
        expect(listing["price"]["currency"]).to eq("USD")
        expect(listing["price"]["formatted"]).to eq("$48.00")
        expect(listing["tags"]).to eq(["cozy", "cosmic"])
      end

      it "includes image data" do
        get "/catalog"
        json = JSON.parse(response.body)
        listing = json["listings"].first

        expect(listing["image"]).to have_key("url")
        expect(listing["image"]).to have_key("alt")
      end
    end

    context "when only seeded data exists" do
      it "returns seeded listings" do
        get "/catalog"
        json = JSON.parse(response.body)
        # Seeded data should be present
        expect(json["listings"].size).to be >= 1
      end
    end
  end

  describe "GET /catalog/:slug" do
    context "when published listing exists" do
      let!(:listing) do
        create(:cat_listing_record, :published,
          name: "Test Detail Cat",
          slug: "test-detail-cat-#{SecureRandom.hex(4)}",
          description: "A cat for detail testing",
          price_cents: 4800,
          image_url: "https://example.com/cat.jpg",
          image_alt: "Test cat",
          tags: ["cozy", "cosmic"])
      end

      it "returns 200 OK" do
        get "/catalog/#{listing.slug}"
        expect(response).to have_http_status(:ok)
      end

      it "returns the listing details" do
        get "/catalog/#{listing.slug}"
        json = JSON.parse(response.body)

        expect(json["id"]).to eq(listing.id)
        expect(json["name"]).to eq("Test Detail Cat")
        expect(json["slug"]).to eq(listing.slug)
        expect(json["description"]).to eq("A cat for detail testing")
        expect(json["price"]["cents"]).to eq(4800)
        expect(json["price"]["formatted"]).to eq("$48.00")
        expect(json["image"]["url"]).to eq("https://example.com/cat.jpg")
        expect(json["image"]["alt"]).to eq("Test cat")
        expect(json["tags"]).to eq(["cozy", "cosmic"])
      end
    end

    context "when listing does not exist" do
      it "returns 404 Not Found" do
        get "/catalog/non-existent-cat-#{SecureRandom.hex(8)}"
        expect(response).to have_http_status(:not_found)
      end

      it "returns error body" do
        get "/catalog/non-existent-cat-#{SecureRandom.hex(8)}"
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("not_found")
        expect(json["message"]).to be_present
      end
    end

    context "when listing exists but is draft" do
      let!(:draft) do
        create(:cat_listing_record, :draft, slug: "draft-test-#{SecureRandom.hex(4)}")
      end

      it "returns 404 Not Found" do
        get "/catalog/#{draft.slug}"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when listing exists but is archived" do
      let!(:archived) do
        create(:cat_listing_record, :archived, slug: "archived-test-#{SecureRandom.hex(4)}")
      end

      it "returns 404 Not Found" do
        get "/catalog/#{archived.slug}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
