# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Persistence
      module Mappers
        class CatListingMapper
          def to_domain(record)
            profile = if record.age_months || record.traits&.any? || record.temperament
              ValueObjects::CatProfile.new(
                age_months: record.age_months,
                traits: ValueObjects::TraitSet.new(values: record.traits || []),
                temperament: record.temperament
              )
            end

            Aggregates::CatListing.new(
              id: ValueObjects::CatId.new(value: record.id),
              name: ValueObjects::CatName.new(value: record.name),
              description: ValueObjects::ContentBlock.new(text: record.description || ""),
              price: ValueObjects::Money.new(
                amount_cents: record.price_cents || 0,
                currency: record.currency || "USD"
              ),
              slug: ValueObjects::Slug.new(value: record.slug),
              visibility: ValueObjects::Visibility.new(value: record.visibility.to_sym),
              tags: ValueObjects::TagList.new(values: record.tags || []),
              profile: profile,
              media: record.image_url ? ValueObjects::CatMedia.new(
                url: record.image_url,
                alt_text: record.image_alt
              ) : nil
            )
          end

          def to_record(aggregate)
            ::CatListingRecord.find_or_initialize_by(id: aggregate.id.to_s).tap do |r|
              r.name = aggregate.name.to_s
              r.description = aggregate.description.to_s
              r.price_cents = aggregate.price.amount_cents
              r.currency = aggregate.price.currency
              r.slug = aggregate.slug.to_s
              r.visibility = aggregate.visibility.to_sym.to_s
              r.tags = aggregate.tags.to_a

              # Map profile if present
              if aggregate.profile
                r.age_months = aggregate.profile.age_months
                r.traits = aggregate.profile.traits.to_a
                r.temperament = aggregate.profile.temperament
              else
                r.age_months = nil
                r.traits = []
                r.temperament = nil
              end

              r.image_url = aggregate.media&.url
              r.image_alt = aggregate.media&.alt_text
            end
          end
        end
      end
    end
  end
end

