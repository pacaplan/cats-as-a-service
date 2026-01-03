# frozen_string_literal: true

module CatContent
  # CatListing Aggregate Root
  #
  # Premade, curated, globally visible cat in the Cat-alog.
  # Root aggregate for catalog browsing.
  #
  # Invariants:
  # - must have name
  # - must have description
  # - base_price must be positive
  #
  # Lifecycle: draft (private) -> published -> archived
  class CatListing < Rampart::Domain::AggregateRoot
    attribute :id, Rampart::Types::String
    attribute :name, CatContent::CatName
    attribute :slug, Rampart::Types::String
    attribute :description, CatContent::CatDescription
    attribute :price, CatContent::Money
    attribute :visibility, CatContent::Visibility
    attribute :image, CatContent::CatMedia
    attribute :tags, CatContent::TagList
    attribute :created_at, Rampart::Types::Time.optional.default(nil)
    attribute :updated_at, Rampart::Types::Time.optional.default(nil)

    def published?
      visibility.published?
    end

    def draft?
      visibility.private?
    end

    def archived?
      visibility.archived?
    end

    def publish
      self.class.new(**attributes.merge(visibility: Visibility.published))
    end

    def archive
      self.class.new(**attributes.merge(visibility: Visibility.archived))
    end
  end
end

