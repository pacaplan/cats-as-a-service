# frozen_string_literal: true

module CatContent
  module Aggregates
    class CustomCat < Rampart::Domain::AggregateRoot
      class InvariantViolation < Rampart::Domain::DomainException; end

      attribute :id, ValueObjects::CatId
      attribute :user_id, Types::String
      attribute :name, ValueObjects::CatName
      attribute :description, ValueObjects::ContentBlock
      attribute :visibility, ValueObjects::Visibility
      attribute :prompt_text, Types::String.optional.default(nil)
      attribute :story_text, ValueObjects::ContentBlock.optional.default(nil)
      attribute :media, ValueObjects::CatMedia.optional.default(nil)
      attribute :tags, ValueObjects::TagList.optional.default(nil)
      attribute :created_at, Types::Time.optional.default(nil)

      delegate :public?, :private?, :archived?, to: :visibility

      def self.create(id:, user_id:, name:, description:, visibility: nil, prompt_text: nil, story_text: nil, media: nil, tags: nil, created_at: nil)
        new(
          id: id,
          user_id: user_id,
          name: name,
          description: description,
          visibility: visibility || ValueObjects::Visibility.new(value: :private),
          prompt_text: prompt_text,
          story_text: story_text,
          media: media,
          tags: tags || ValueObjects::TagList.new(values: []),
          created_at: created_at
        )
      end

      def regenerate_description(new_description:)
        new_attrs = attributes.merge(
          description: new_description
        )
        self.class.new(**new_attrs)
      end

      def archive
        new_attrs = attributes.merge(
          visibility: ValueObjects::Visibility.new(value: :archived)
        )
        self.class.new(**new_attrs)
      end
    end
  end
end
