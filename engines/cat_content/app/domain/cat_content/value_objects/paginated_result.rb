# frozen_string_literal: true

module CatContent
  module ValueObjects
    class PaginatedResult < Rampart::Domain::ValueObject
      attribute :items, Rampart::Types::Array
      attribute :total_count, Rampart::Types::Integer
      attribute :page, Rampart::Types::Integer
      attribute :per_page, Rampart::Types::Integer

      def total_pages
        (total_count.to_f / per_page).ceil
      end

      def has_next_page?
        page < total_pages
      end

      def has_previous_page?
        page > 1
      end

      def to_meta
        {
          page: page,
          per_page: per_page,
          total: total_count
        }
      end
    end
  end
end

