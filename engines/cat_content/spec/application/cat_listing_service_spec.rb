# frozen_string_literal: true

require "rails_helper"

RSpec.describe CatContent::CatListingService do
  let(:repository) { instance_double(CatContent::CatListingRepository) }
  subject(:service) { described_class.new(cat_listing_repo: repository) }

  let(:sample_listing) do
    CatContent::CatListing.new(
      id: SecureRandom.uuid,
      name: CatContent::CatName.new(value: "Nebula Neko"),
      slug: "nebula-neko",
      description: CatContent::CatDescription.new(value: "A cosmic cat"),
      price: CatContent::Money.new(cents: 4800, currency: "USD"),
      visibility: CatContent::Visibility.published,
      image: CatContent::CatMedia.new(url: "https://example.com/cat.jpg", alt: "Cat"),
      tags: CatContent::TagList.new(values: ["cozy"]),
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe "#list_published" do
    context "when listings exist" do
      before do
        allow(repository).to receive(:find_all_published).and_return([sample_listing])
      end

      it "returns Success with listings" do
        result = service.list_published
        expect(result).to be_success
        expect(result.value!).to eq([sample_listing])
      end
    end

    context "when no listings exist" do
      before do
        allow(repository).to receive(:find_all_published).and_return([])
      end

      it "returns Success with empty array" do
        result = service.list_published
        expect(result).to be_success
        expect(result.value!).to eq([])
      end
    end

    context "when repository raises an error" do
      before do
        allow(repository).to receive(:find_all_published).and_raise(StandardError.new("DB error"))
      end

      it "returns Failure with error" do
        result = service.list_published
        expect(result).to be_failure
      end
    end
  end

  describe "#find_by_slug" do
    context "when listing exists and is published" do
      before do
        allow(repository).to receive(:find_by_slug).with("nebula-neko").and_return(sample_listing)
      end

      it "returns Success with the listing" do
        result = service.find_by_slug("nebula-neko")
        expect(result).to be_success
        expect(result.value!.name.value).to eq("Nebula Neko")
      end
    end

    context "when listing does not exist" do
      before do
        allow(repository).to receive(:find_by_slug).with("non-existent").and_return(nil)
      end

      it "returns Failure with :not_found symbol" do
        result = service.find_by_slug("non-existent")
        expect(result).to be_failure
        expect(result.failure).to eq(:not_found)
      end
    end

    context "when listing exists but is not published" do
      let(:draft_listing) do
        CatContent::CatListing.new(
          id: SecureRandom.uuid,
          name: CatContent::CatName.new(value: "Draft Cat"),
          slug: "draft-cat",
          description: CatContent::CatDescription.new(value: "A draft"),
          price: CatContent::Money.new(cents: 1000, currency: "USD"),
          visibility: CatContent::Visibility.private,
          image: CatContent::CatMedia.new(url: nil, alt: nil),
          tags: CatContent::TagList.new(values: []),
          created_at: Time.now,
          updated_at: Time.now
        )
      end

      before do
        allow(repository).to receive(:find_by_slug).with("draft-cat").and_return(draft_listing)
      end

      it "returns Failure with :not_found symbol" do
        result = service.find_by_slug("draft-cat")
        expect(result).to be_failure
        expect(result.failure).to eq(:not_found)
      end
    end

    context "when repository raises an error" do
      before do
        allow(repository).to receive(:find_by_slug).and_raise(StandardError.new("DB error"))
      end

      it "returns Failure with error" do
        result = service.find_by_slug("any-slug")
        expect(result).to be_failure
      end
    end
  end
end
