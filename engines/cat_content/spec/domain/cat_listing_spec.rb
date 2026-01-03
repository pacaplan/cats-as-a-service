# frozen_string_literal: true

require "rails_helper"

RSpec.describe CatContent::CatListing do
  let(:valid_attributes) do
    {
      id: SecureRandom.uuid,
      name: CatContent::CatName.new(value: "Nebula Neko"),
      slug: "nebula-neko",
      description: CatContent::CatDescription.new(value: "A cosmic cat"),
      price: CatContent::Money.new(cents: 4800, currency: "USD"),
      visibility: CatContent::Visibility.published,
      image: CatContent::CatMedia.new(url: "https://example.com/cat.jpg", alt: "Cat image"),
      tags: CatContent::TagList.new(values: ["cozy", "cosmic"]),
      created_at: Time.now,
      updated_at: Time.now
    }
  end

  subject(:cat_listing) { described_class.new(**valid_attributes) }

  describe "initialization" do
    it "creates a valid aggregate with all attributes" do
      expect(cat_listing).to be_a(described_class)
      expect(cat_listing.name.value).to eq("Nebula Neko")
      expect(cat_listing.slug).to eq("nebula-neko")
      expect(cat_listing.price.cents).to eq(4800)
    end

    it "inherits from AggregateRoot" do
      expect(described_class.ancestors).to include(Rampart::Domain::AggregateRoot)
    end
  end

  describe "visibility state queries" do
    context "when published" do
      let(:listing) { described_class.new(**valid_attributes.merge(visibility: CatContent::Visibility.published)) }

      it { expect(listing.published?).to be true }
      it { expect(listing.draft?).to be false }
      it { expect(listing.archived?).to be false }
    end

    context "when draft (private)" do
      let(:listing) { described_class.new(**valid_attributes.merge(visibility: CatContent::Visibility.private)) }

      it { expect(listing.published?).to be false }
      it { expect(listing.draft?).to be true }
      it { expect(listing.archived?).to be false }
    end

    context "when archived" do
      let(:listing) { described_class.new(**valid_attributes.merge(visibility: CatContent::Visibility.archived)) }

      it { expect(listing.published?).to be false }
      it { expect(listing.draft?).to be false }
      it { expect(listing.archived?).to be true }
    end
  end

  describe "#publish" do
    let(:draft_listing) { described_class.new(**valid_attributes.merge(visibility: CatContent::Visibility.private)) }

    it "returns a new listing with published visibility" do
      published = draft_listing.publish
      expect(published.published?).to be true
      expect(published.visibility).not_to eq(draft_listing.visibility)
    end

    it "does not mutate the original listing" do
      draft_listing.publish
      expect(draft_listing.draft?).to be true
    end
  end

  describe "#archive" do
    it "returns a new listing with archived visibility" do
      archived = cat_listing.archive
      expect(archived.archived?).to be true
      expect(archived.visibility).not_to eq(cat_listing.visibility)
    end

    it "does not mutate the original listing" do
      cat_listing.archive
      expect(cat_listing.published?).to be true
    end
  end
end
