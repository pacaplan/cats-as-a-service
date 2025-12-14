# frozen_string_literal: true

module CatContent
  module Aggregates
    class CatListing < Rampart::Domain::AggregateRoot
      # Invariant errors
      class InvariantViolation < Rampart::Domain::DomainException; end
      class MissingMediaForPublish < InvariantViolation
        def initialize
          super("A cat listing must have at least one image to be published")
        end
      end
      class MissingDescriptionForPublish < InvariantViolation
        def initialize
          super("A cat listing must have a description to be published")
        end
      end

      attribute :id, ValueObjects::CatId
      attribute :name, ValueObjects::CatName
      attribute :description, ValueObjects::ContentBlock
      attribute :price, ValueObjects::Money
      attribute :slug, ValueObjects::Slug
      attribute :visibility, ValueObjects::Visibility
      attribute :tags, ValueObjects::TagList
      attribute :profile, ValueObjects::CatProfile.optional.default(nil)
      attribute :media, ValueObjects::CatMedia.optional.default(nil)

      delegate :public?, :private?, :archived?, to: :visibility

      # Factory method for creating a new draft cat listing
      def self.create(id:, name:, description:, price:, slug:, tags: nil, profile: nil, media: nil)
        new(
          id: id,
          name: name,
          description: description,
          price: price,
          slug: slug,
          visibility: ValueObjects::Visibility.new(value: :private),
          tags: tags || ValueObjects::TagList.new(values: []),
          profile: profile,
          media: media
        )
      end

      # Publish the listing - enforces invariants
      def publish
        validate_publishable!
        new_attrs = attributes.merge(
          visibility: ValueObjects::Visibility.new(value: :public)
        )
        self.class.new(**new_attrs)
      end

      # Archive the listing
      def archive
        new_attrs = attributes.merge(
          visibility: ValueObjects::Visibility.new(value: :archived)
        )
        self.class.new(**new_attrs)
      end

      # Check if listing can be published
      def publishable?
        media.present? && description.text.present?
      end

      private

      def validate_publishable!
        raise MissingMediaForPublish unless media.present?
        raise MissingDescriptionForPublish if description.text.blank?
      end
    end
  end
end


