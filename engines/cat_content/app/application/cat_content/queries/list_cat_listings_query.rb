# frozen_string_literal: true

module CatContent
  module Queries
    class ListCatListingsQuery < Rampart::Application::Query
      attribute :tags, Rampart::Types::Array.of(Rampart::Types::String).default([].freeze)
      attribute :page, Rampart::Types::Integer.default(1)
      attribute :per_page, Rampart::Types::Integer.default(20)
    end
  end
end

