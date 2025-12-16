# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Persistence
      module Mappers
        class CustomCatMapper
          def to_domain(record)
            Aggregates::CustomCat.new(
              id: ValueObjects::CatId.new(value: record.id),
              user_id: record.user_id,
              name: ValueObjects::CatName.new(value: record.name),
              description: ValueObjects::ContentBlock.new(text: record.description || ""),
              visibility: ValueObjects::Visibility.new(value: record.visibility.to_sym),
              prompt_text: record.prompt_text,
              story_text: record.story_text ? ValueObjects::ContentBlock.new(text: record.story_text) : nil,
              media: record.image_url ? ValueObjects::CatMedia.new(
                url: record.image_url,
                alt_text: record.image_alt
              ) : nil,
              tags: ValueObjects::TagList.new(values: record.tags || []),
              created_at: record.created_at
            )
          end

          def to_record(aggregate)
            CatContent::CustomCatRecord.find_or_initialize_by(id: aggregate.id.to_s).tap do |r|
              r.user_id = aggregate.user_id
              r.name = aggregate.name.to_s
              r.description = aggregate.description.to_s
              r.visibility = aggregate.visibility.to_sym.to_s
              r.prompt_text = aggregate.prompt_text
              r.story_text = aggregate.story_text&.to_s
              r.image_url = aggregate.media&.url
              r.image_alt = aggregate.media&.alt_text
              r.tags = aggregate.tags&.to_a || []
              r.created_at = aggregate.created_at
            end
          end
        end
      end
    end
  end
end
