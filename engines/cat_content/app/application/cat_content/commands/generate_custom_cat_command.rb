# frozen_string_literal: true

module CatContent
  module Commands
    class GenerateCustomCatCommand < Rampart::Application::Command
      attribute :prompt, Rampart::Types::String
      attribute :name, Rampart::Types::String.optional.default(nil)
      attribute :tags, Rampart::Types::Array.of(Rampart::Types::String).default([].freeze)
    end
  end
end
