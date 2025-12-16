# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Adapters
      class OpenAIApiLanguageModelAdapter < Ports::LanguageModelPort
        def generate_description(prompt:)
           # In real implementation: call OpenAI
           "A generated description for: #{prompt}"
        end
        
        def generate_story(prompt:)
           "A generated story for: #{prompt}"
        end
      end
    end
  end
end
