# frozen_string_literal: true

module CatContent
  module Services
    class CustomCatService < Rampart::Application::Service
      def initialize(custom_cat_repo:, language_model_port:, clock_port:, id_generator_port:, transaction_port:, event_bus_port: nil)
        @custom_cat_repo = custom_cat_repo
        @language_model_port = language_model_port
        @clock_port = clock_port
        @id_generator_port = id_generator_port
        @transaction_port = transaction_port
        @event_bus_port = event_bus_port
      end

      def list(user_id:, page: 1, per_page: 20, include_archived: false)
        @custom_cat_repo.list_by_user(
          user_id: user_id, 
          page: page, 
          per_page: per_page,
          include_archived: include_archived
        )
      end

      def get(user_id:, id:)
         @custom_cat_repo.find_by_user_and_id(user_id: user_id, id: ValueObjects::CatId.new(value: id))
      end

      def generate(user_id:, command:)
        @transaction_port.transaction do
          cat_id = ValueObjects::CatId.new(value: @id_generator_port.generate)
          
          description_text = @language_model_port.generate_description(prompt: command.prompt)
          
          
          name = ValueObjects::CatName.new(value: command.name || "Unnamed Cat")
          description = ValueObjects::ContentBlock.new(text: description_text, format: "markdown")
          # Placeholder for image generation
          media = ValueObjects::CatMedia.new(url: "https://placekitten.com/400/400", alt_text: "A generated cat")

          custom_cat = Aggregates::CustomCat.create(
            id: cat_id,
            user_id: user_id,
            name: name,
            description: description,
            visibility: ValueObjects::Visibility.new(value: :private),
            prompt_text: command.prompt,
            tags: ValueObjects::TagList.new(values: command.tags),
            media: media,
            created_at: @clock_port.now
          )

          @custom_cat_repo.add(custom_cat)

          if @event_bus_port
             event = Events::CustomCatCreated.new(
               custom_cat_id: custom_cat.id,
               user_id: user_id,
               name: custom_cat.name.value,
               occurred_at: @clock_port.now,
               schema_version: 1
             )
             @event_bus_port.publish(event: event)
          end

          custom_cat
        end
      end

      def regenerate_description(user_id:, id:, command:)
        @transaction_port.transaction do
           custom_cat = @custom_cat_repo.find_by_user_and_id(user_id: user_id, id: ValueObjects::CatId.new(value: id))
           raise CatContent::ResourceNotFound unless custom_cat

           prompt = command.prompt || custom_cat.prompt_text || "A cat"
           new_description_text = @language_model_port.generate_description(prompt: prompt)
           new_description = ValueObjects::ContentBlock.new(text: new_description_text, format: "markdown")

           updated_cat = custom_cat.regenerate_description(new_description: new_description)
           @custom_cat_repo.update(updated_cat)

           if @event_bus_port
             event = Events::CatDescriptionRegenerated.new(
               cat_id: updated_cat.id,
               description_text: new_description.text,
               occurred_at: @clock_port.now,
               schema_version: 1
             )
             @event_bus_port.publish(event: event)
           end
           
           updated_cat
        end
      end
      
      def archive(user_id:, id:)
        @transaction_port.transaction do
           custom_cat = @custom_cat_repo.find_by_user_and_id(user_id: user_id, id: ValueObjects::CatId.new(value: id))
           raise CatContent::ResourceNotFound unless custom_cat
           
           archived_cat = custom_cat.archive
           @custom_cat_repo.update(archived_cat)
           
           if @event_bus_port
             event = Events::CustomCatArchived.new(
               custom_cat_id: archived_cat.id,
               user_id: user_id,
               occurred_at: @clock_port.now,
               schema_version: 1
             )
             @event_bus_port.publish(event: event)
           end

           archived_cat
        end
      end
      
      def list_all(page:, per_page:)
         @custom_cat_repo.list_all(page: page, per_page: per_page)
      end
    end
  end
end
