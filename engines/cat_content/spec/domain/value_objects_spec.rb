# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CatContent Value Objects" do
  describe CatContent::CatName do
    it "creates a valid name" do
      name = described_class.new(value: "Nebula Neko")
      expect(name.value).to eq("Nebula Neko")
    end

    it "rejects empty names" do
      expect { described_class.new(value: "") }.to raise_error(Dry::Struct::Error)
    end

    it "rejects names over 100 characters" do
      expect { described_class.new(value: "a" * 101) }.to raise_error(Dry::Struct::Error)
    end

    it "inherits from ValueObject" do
      expect(described_class.ancestors).to include(Rampart::Domain::ValueObject)
    end
  end

  describe CatContent::CatDescription do
    it "creates a valid description" do
      desc = described_class.new(value: "A wonderful cat")
      expect(desc.value).to eq("A wonderful cat")
    end

    it "rejects empty descriptions" do
      expect { described_class.new(value: "") }.to raise_error(Dry::Struct::Error)
    end
  end

  describe CatContent::Money do
    it "creates money with cents and currency" do
      money = described_class.new(cents: 4800, currency: "USD")
      expect(money.cents).to eq(4800)
      expect(money.currency).to eq("USD")
    end

    it "formats as currency string" do
      money = described_class.new(cents: 4800, currency: "USD")
      expect(money.formatted).to eq("$48.00")
    end

    it "handles single digit cents" do
      money = described_class.new(cents: 101, currency: "USD")
      expect(money.formatted).to eq("$1.01")
    end

    it "rejects zero cents" do
      expect { described_class.new(cents: 0, currency: "USD") }.to raise_error(Dry::Struct::Error)
    end

    it "rejects negative cents" do
      expect { described_class.new(cents: -100, currency: "USD") }.to raise_error(Dry::Struct::Error)
    end
  end

  describe CatContent::Visibility do
    describe ".published" do
      it "creates a published visibility" do
        vis = described_class.published
        expect(vis.value).to eq("published")
        expect(vis.published?).to be true
      end
    end

    describe ".private" do
      it "creates a private (draft) visibility" do
        vis = described_class.private
        expect(vis.value).to eq("private")
        expect(vis.private?).to be true
      end
    end

    describe ".archived" do
      it "creates an archived visibility" do
        vis = described_class.archived
        expect(vis.value).to eq("archived")
        expect(vis.archived?).to be true
      end
    end

    it "rejects invalid values" do
      expect { described_class.new(value: "invalid") }.to raise_error(Dry::Struct::Error)
    end
  end

  describe CatContent::Slug do
    it "creates a valid slug" do
      slug = described_class.new(value: "nebula-neko")
      expect(slug.value).to eq("nebula-neko")
    end

    it "generates slug from name" do
      slug = described_class.generate("Nebula Neko")
      expect(slug.value).to eq("nebula-neko")
    end

    it "handles special characters in name" do
      slug = described_class.generate("Cat's Meow!")
      expect(slug.value).to match(/^[a-z0-9-]+$/)
    end
  end

  describe CatContent::TagList do
    it "creates from array" do
      tags = described_class.new(values: ["cozy", "cosmic"])
      expect(tags.values).to eq(["cozy", "cosmic"])
    end

    it "parses comma-separated string via .from" do
      tags = described_class.from("cozy, cosmic, friendly")
      expect(tags.values).to eq(["cozy", "cosmic", "friendly"])
    end

    it "handles empty array" do
      tags = described_class.new(values: [])
      expect(tags.values).to eq([])
    end
  end

  describe CatContent::CatMedia do
    it "creates with url and alt" do
      media = described_class.new(url: "https://example.com/cat.jpg", alt: "A cat")
      expect(media.url).to eq("https://example.com/cat.jpg")
      expect(media.alt).to eq("A cat")
    end

    it "allows nil values" do
      media = described_class.new(url: nil, alt: nil)
      expect(media.url).to be_nil
      expect(media.alt).to be_nil
    end
  end
end
