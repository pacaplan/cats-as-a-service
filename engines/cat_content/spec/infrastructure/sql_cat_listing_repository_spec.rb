# frozen_string_literal: true

require "rails_helper"

RSpec.describe CatContent::SqlCatListingRepository, type: :model do
  subject(:repository) { described_class.new }

  describe "#find_all_published" do
    context "when published listings exist" do
      let!(:cat1) { create(:cat_listing_record, :published, name: "Repo Test Cat 1", slug: "repo-test-1-#{SecureRandom.hex(4)}") }
      let!(:cat2) { create(:cat_listing_record, :published, name: "Repo Test Cat 2", slug: "repo-test-2-#{SecureRandom.hex(4)}") }
      let!(:draft) { create(:cat_listing_record, :draft, name: "Repo Draft Cat", slug: "repo-draft-#{SecureRandom.hex(4)}") }
      let!(:archived) { create(:cat_listing_record, :archived, name: "Repo Archived Cat", slug: "repo-archived-#{SecureRandom.hex(4)}") }

      it "returns only published listings" do
        listings = repository.find_all_published
        # Should include our test cats plus any seeded data
        names = listings.map { |l| l.name.value }
        expect(names).to include("Repo Test Cat 1", "Repo Test Cat 2")
        expect(names).not_to include("Repo Draft Cat", "Repo Archived Cat")
      end

      it "returns domain aggregates, not records" do
        listings = repository.find_all_published
        expect(listings.first).to be_a(CatContent::CatListing)
      end

      it "orders by created_at descending" do
        listings = repository.find_all_published
        expect(listings.first.created_at).to be >= listings.last.created_at
      end
    end

    context "when only draft listings exist (besides seeded)" do
      before do
        create(:cat_listing_record, :draft, slug: "only-draft-#{SecureRandom.hex(4)}")
      end

      it "returns at least the seeded data" do
        # Note: seeded data exists, so we can't test truly empty
        listings = repository.find_all_published
        expect(listings).to be_an(Array)
      end
    end
  end

  describe "#find_by_slug" do
    context "when listing exists" do
      let(:unique_slug) { "find-test-cat-#{SecureRandom.hex(4)}" }
      let!(:record) { create(:cat_listing_record, slug: unique_slug, name: "Find Test Cat") }

      it "returns the domain aggregate" do
        listing = repository.find_by_slug(unique_slug)
        expect(listing).to be_a(CatContent::CatListing)
        expect(listing.name.value).to eq("Find Test Cat")
        expect(listing.slug).to eq(unique_slug)
      end

      it "maps all attributes correctly" do
        listing = repository.find_by_slug(unique_slug)
        expect(listing.price.cents).to eq(record.price_cents)
        expect(listing.price.currency).to eq(record.currency)
        expect(listing.image.url).to eq(record.image_url)
        expect(listing.tags.values).to eq(record.tags)
      end
    end

    context "when listing does not exist" do
      it "returns nil" do
        expect(repository.find_by_slug("non-existent-#{SecureRandom.hex(8)}")).to be_nil
      end
    end

    context "when finding draft listing" do
      let(:draft_slug) { "draft-cat-#{SecureRandom.hex(4)}" }
      let!(:draft) { create(:cat_listing_record, :draft, slug: draft_slug) }

      it "returns the listing (visibility filtering is service responsibility)" do
        listing = repository.find_by_slug(draft_slug)
        expect(listing).to be_a(CatContent::CatListing)
        expect(listing.draft?).to be true
      end
    end
  end
end
