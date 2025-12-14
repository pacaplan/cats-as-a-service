# frozen_string_literal: true

FactoryBot.define do
  factory :cat_listing_record, class: "CatListingRecord" do
    sequence(:id) { |n| SecureRandom.uuid }
    sequence(:name) { |n| "Cat #{n}" }
    sequence(:slug) { |n| "cat-#{n}" }
    description { "A lovely cat" }
    price_cents { 9999 }
    currency { "USD" }
    visibility { "private" }
    image_url { "https://example.com/cat.jpg" }
    image_alt { "A cute cat" }
    tags { ["fluffy", "playful"] }
    age_months { 24 }
    temperament { "Friendly" }
    traits { ["playful", "curious"] }

    trait :published do
      visibility { "public" }
    end

    trait :archived do
      visibility { "archived" }
    end

    trait :with_profile do
      age_months { 24 }
      temperament { "Dignified observer" }
      traits { ["fluffy", "dignified", "mysterious"] }
    end

    trait :minimal do
      age_months { nil }
      temperament { nil }
      traits { [] }
    end
  end
end


