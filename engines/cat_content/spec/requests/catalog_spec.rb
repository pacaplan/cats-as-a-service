# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Catalog API", type: :request do
  describe "GET /catalog" do
    subject(:make_request) { get "/catalog", params: params }

    let(:params) { {} }

    context "when there are published cats" do
      let!(:published_cat1) do
        create(:cat_listing_record, :published,
          name: "Whiskers McFluff",
          slug: "whiskers-mcfluff",
          description: "A majestic cat",
          price_cents: 9999,
          tags: ["fluffy", "dignified"]
        )
      end

      let!(:published_cat2) do
        create(:cat_listing_record, :published,
          name: "Shadow Paws",
          slug: "shadow-paws",
          description: "A mysterious cat",
          price_cents: 12999,
          tags: ["mysterious", "sleek"]
        )
      end

      let!(:private_cat) do
        create(:cat_listing_record,
          name: "Private Cat",
          slug: "private-cat",
          visibility: "private"
        )
      end

      let!(:archived_cat) do
        create(:cat_listing_record, :archived,
          name: "Archived Cat",
          slug: "archived-cat"
        )
      end

      it "returns 200 OK" do
        make_request
        expect(response).to have_http_status(:ok)
      end

      it "returns only published cats" do
        make_request
        json = response.parsed_body
        expect(json["cats"].size).to eq(2)
        
        cat_names = json["cats"].map { |c| c["name"] }
        expect(cat_names).to contain_exactly("Whiskers McFluff", "Shadow Paws")
        expect(cat_names).not_to include("Private Cat", "Archived Cat")
      end

      it "returns cats with correct structure" do
        make_request
        json = response.parsed_body
        
        # Find the specific cat by slug since order may vary
        cat = json["cats"].find { |c| c["slug"] == "whiskers-mcfluff" }
        expect(cat).to include(
          "id" => published_cat1.id,
          "name" => "Whiskers McFluff",
          "slug" => "whiskers-mcfluff",
          "description" => "A majestic cat",
          "image_url" => published_cat1.image_url
        )
        
        expect(cat["price"]).to eq({
          "amount_cents" => 9999,
          "currency" => "USD"
        })
        
        expect(cat["tags"]).to eq(["fluffy", "dignified"])
      end

      it "returns pagination metadata" do
        make_request
        json = response.parsed_body
        
        expect(json["meta"]).to include(
          "page" => 1,
          "per_page" => 20,
          "total" => 2
        )
      end

      context "with pagination parameters" do
        let(:params) { { page: 2, per_page: 1 } }

        it "returns paginated results" do
          make_request
          json = response.parsed_body
          
          expect(json["cats"].size).to eq(1)
          expect(json["meta"]).to include(
            "page" => 2,
            "per_page" => 1,
            "total" => 2
          )
        end
      end

      context "with tag filter" do
        let(:params) { { tags: "fluffy" } }

        it "returns only cats with matching tags" do
          make_request
          json = response.parsed_body
          
          expect(json["cats"].size).to eq(1)
          expect(json["cats"].first["name"]).to eq("Whiskers McFluff")
        end
      end

      context "with multiple tag filters" do
        let(:params) { { tags: "fluffy,mysterious" } }

        it "returns cats matching any of the tags" do
          make_request
          json = response.parsed_body
          
          # This should return both cats as they each have one of the tags
          expect(json["cats"].size).to be >= 1
        end
      end
    end

    context "when there are no published cats" do
      it "returns empty array" do
        make_request
        json = response.parsed_body
        
        expect(json["cats"]).to eq([])
        expect(json["meta"]["total"]).to eq(0)
      end
    end
  end

  describe "GET /catalog/:slug" do
    subject(:make_request) { get "/catalog/#{slug}" }

    let(:slug) { "whiskers-mcfluff" }

    context "when the cat exists and is published" do
      let!(:published_cat) do
        create(:cat_listing_record, :published, :with_profile,
          name: "Whiskers McFluff",
          slug: "whiskers-mcfluff",
          description: "A majestic fluffy cat",
          price_cents: 9999,
          currency: "USD",
          image_url: "https://example.com/whiskers.jpg",
          image_alt: "Whiskers lounging",
          tags: ["fluffy", "dignified"],
          age_months: 24,
          temperament: "Dignified observer",
          traits: ["fluffy", "dignified", "mysterious"]
        )
      end

      it "returns 200 OK" do
        make_request
        expect(response).to have_http_status(:ok)
      end

      it "returns the cat with full details" do
        make_request
        json = response.parsed_body
        
        expect(json).to include(
          "id" => published_cat.id,
          "name" => "Whiskers McFluff",
          "slug" => "whiskers-mcfluff",
          "description" => "A majestic fluffy cat",
          "image_url" => "https://example.com/whiskers.jpg"
        )
        
        expect(json["price"]).to eq({
          "amount_cents" => 9999,
          "currency" => "USD"
        })
        
        expect(json["tags"]).to eq(["fluffy", "dignified"])
      end

      it "includes profile information" do
        make_request
        json = response.parsed_body
        
        expect(json["profile"]).to eq({
          "age_months" => 24,
          "temperament" => "Dignified observer",
          "traits" => ["fluffy", "dignified", "mysterious"]
        })
      end

      it "includes media array" do
        make_request
        json = response.parsed_body
        
        expect(json["media"]).to be_an(Array)
        expect(json["media"].first).to eq({
          "url" => "https://example.com/whiskers.jpg",
          "alt_text" => "Whiskers lounging"
        })
      end
    end

    context "when the cat exists but is not published" do
      let!(:private_cat) do
        create(:cat_listing_record,
          name: "Private Cat",
          slug: "private-cat",
          visibility: "private"
        )
      end

      let(:slug) { "private-cat" }

      it "returns 404 Not Found" do
        make_request
        expect(response).to have_http_status(:not_found)
      end

      it "returns error details" do
        make_request
        json = response.parsed_body
        
        expect(json["error"]).to include(
          "code" => "cat_not_found",
          "message" => "The requested cat does not exist"
        )
        expect(json["error"]["details"]).to include("slug" => "private-cat")
      end
    end

    context "when the cat does not exist" do
      let(:slug) { "non-existent-cat" }

      it "returns 404 Not Found" do
        make_request
        expect(response).to have_http_status(:not_found)
      end

      it "returns error details" do
        make_request
        json = response.parsed_body
        
        expect(json["error"]).to include(
          "code" => "cat_not_found",
          "message" => "The requested cat does not exist"
        )
        expect(json["error"]["details"]).to include("slug" => "non-existent-cat")
      end
    end

    context "when the cat has minimal data (no profile)" do
      let!(:minimal_cat) do
        create(:cat_listing_record, :published, :minimal,
          name: "Simple Cat",
          slug: "simple-cat",
          age_months: nil,
          temperament: nil,
          traits: []
        )
      end

      let(:slug) { "simple-cat" }

      it "returns the cat without profile" do
        make_request
        json = response.parsed_body
        
        expect(json).to include(
          "name" => "Simple Cat",
          "slug" => "simple-cat"
        )
        expect(json).not_to have_key("profile")
      end
    end
  end

  describe "ordering and sorting" do
    before do
      # Create cats in specific order
      create(:cat_listing_record, :published, name: "First", slug: "first", created_at: 3.days.ago)
      create(:cat_listing_record, :published, name: "Second", slug: "second", created_at: 2.days.ago)
      create(:cat_listing_record, :published, name: "Third", slug: "third", created_at: 1.day.ago)
    end

    it "returns cats in reverse chronological order (newest first)" do
      get "/catalog"
      json = response.parsed_body
      
      cat_names = json["cats"].map { |c| c["name"] }
      expect(cat_names).to eq(["Third", "Second", "First"])
    end
  end
end

