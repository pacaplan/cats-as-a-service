# frozen_string_literal: true

FactoryBot.define do
  factory :cat_listing_record, class: "CatContent::CatListingRecord" do
    sequence(:name) { |n| "Test Cat #{n}" }
    sequence(:slug) { |n| "test-cat-#{n}" }
    description { "A wonderful test cat with many features." }
    price_cents { 4800 }
    currency { "USD" }
    visibility { "published" }
    image_url { "https://images.unsplash.com/photo-123" }
    image_alt { "Test cat illustration" }
    tags { ["cozy", "friendly"] }

    trait :draft do
      visibility { "private" }
    end

    trait :archived do
      visibility { "archived" }
    end

    trait :published do
      visibility { "published" }
    end

    trait :free do
      price_cents { 0 }
    end

    trait :expensive do
      price_cents { 99900 }
    end
  end
end
