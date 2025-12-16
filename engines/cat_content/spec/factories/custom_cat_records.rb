FactoryBot.define do
  factory :custom_cat_record, class: "CatContent::CustomCatRecord" do
    id { SecureRandom.uuid }
    user_id { "user_#{SecureRandom.hex(4)}" }
    name { "Fluffy" }
    description { "A generated cat description" }
    visibility { "private" }
    prompt_text { "A cute cat" }
    
    transient do
      story { nil }
      prompt { nil }
    end

    trait :archived do
      visibility { "archived" }
    end

    after(:build) do |cat, evaluator|
      cat.story_text = evaluator.story if evaluator.story
      
      if evaluator.prompt.is_a?(Hash)
        # prompt passed as hash in tests, but model expects string? 
        # The spec passes prompt as hash: { "text" => ..., "quiz_results" => ... }
        # The model `prompt_text` is string.
        # Maybe I should serialize it or just take the text.
        cat.prompt_text = evaluator.prompt["text"]
      elsif evaluator.prompt.is_a?(String)
         cat.prompt_text = evaluator.prompt
      end
    end
  end
end
