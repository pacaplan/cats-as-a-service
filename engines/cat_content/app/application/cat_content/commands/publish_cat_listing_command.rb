# frozen_string_literal: true

module CatContent
  module Commands
    class PublishCatListingCommand < Rampart::Application::Command
      attribute :id, Rampart::Types::String
    end
  end
end
