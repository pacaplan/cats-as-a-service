# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Http
      module Serializers
        class CatListingSerializer
          def initialize(cat_listing)
            @cat = cat_listing
          end

          def as_json
            result = {
              id: @cat.id.to_s,
              name: @cat.name.to_s,
              slug: @cat.slug.to_s,
              description: @cat.description.to_s,
              image_url: @cat.media&.url,
              price: {
                amount_cents: @cat.price.amount_cents,
                currency: @cat.price.currency
              },
              tags: @cat.tags.to_a
            }

            result
          end

          def as_json_full
            result = as_json

            # Include profile if present
            if @cat.profile
              result[:profile] = {
                age_months: @cat.profile.age_months,
                temperament: @cat.profile.temperament,
                traits: @cat.profile.traits.to_a
              }
            end

            # Include media array if present
            if @cat.media
              result[:media] = [
                {
                  url: @cat.media.url,
                  alt_text: @cat.media.alt_text
                }
              ]
            end

            result
          end
        end
      end
    end
  end
end

