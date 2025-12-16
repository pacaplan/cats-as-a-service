# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Http
      module Serializers
        class CustomCatSerializer
          def initialize(custom_cat)
            @cat = custom_cat
          end

          def as_json
            {
              id: @cat.id.to_s,
              user_id: @cat.user_id,
              name: @cat.name.to_s,
              description: @cat.description&.to_s,
              visibility: @cat.visibility.to_sym.to_s,
              image_url: @cat.media&.url,
              tags: @cat.tags&.to_a
            }
          end

          def as_json_full
            result = as_json
            result[:prompt] = { text: @cat.prompt_text }
            result[:story] = @cat.story_text&.to_s
            result[:created_at] = @cat.created_at
            
            if @cat.media
              result[:media] = {
                url: @cat.media.url,
                alt_text: @cat.media.alt_text
              }
            end
            
            result
          end
        end
      end
    end
  end
end
