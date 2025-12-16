# frozen_string_literal: true

module CatContent
  module Commands
    class RegenerateDescriptionCommand < Rampart::Application::Command
      attribute :prompt, Rampart::Types::String.optional.default(nil)
    end
  end
end
