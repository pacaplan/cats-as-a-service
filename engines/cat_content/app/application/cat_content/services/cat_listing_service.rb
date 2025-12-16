# frozen_string_literal: true

module CatContent
  module Services
    class CatListingService < Rampart::Application::Service
      def initialize(cat_listing_repo:, clock_port:, id_generator_port:, transaction_port:, event_bus_port:)
        @cat_listing_repo = cat_listing_repo
        @clock_port = clock_port
        @id_generator_port = id_generator_port
        @transaction_port = transaction_port
        @event_bus_port = event_bus_port
      end

      def list_all(filters:, page:, per_page:)
        @cat_listing_repo.list_all(
          filters: filters,
          page: page,
          per_page: per_page
        )
      end

      # Browse/filter Cat-alog
      # @return [PaginatedResult] paginated list of public cat listings
      def list(query)
        @cat_listing_repo.list_public(
          tags: query.tags,
          page: query.page,
          per_page: query.per_page
        )
      end

      # Retrieve single cat details by slug
      # @return [CatListing, nil] the cat listing or nil if not found
      def get_by_slug(slug)
        @cat_listing_repo.find_by_slug(slug)
      end

      # Retrieve single cat details by id
      # @return [CatListing, nil] the cat listing or nil if not found
      def get(id:)
        @cat_listing_repo.find(ValueObjects::CatId.new(value: id))
      end

      def create(command:)
        @transaction_port.transaction do
          cat_id = ValueObjects::CatId.new(value: @id_generator_port.generate)
          
          # Map command to value objects
          name = ValueObjects::CatName.new(value: command.name)
          description = ValueObjects::ContentBlock.new(text: command.description, format: "markdown")
          price = ValueObjects::Money.new(amount_cents: command.price_cents, currency: command.currency)
          slug = ValueObjects::Slug.new(value: command.slug)
          tags = ValueObjects::TagList.new(values: command.tags)
          
          profile = command.profile ? ValueObjects::CatProfile.new(**command.profile.transform_keys(&:to_sym)) : nil
          media = command.media ? ValueObjects::CatMedia.new(**command.media.transform_keys(&:to_sym)) : nil

          cat_listing = Aggregates::CatListing.create(
            id: cat_id,
            name: name,
            description: description,
            price: price,
            slug: slug,
            tags: tags,
            profile: profile,
            media: media
          )

          if command.publish
            cat_listing = cat_listing.publish
          end

          @cat_listing_repo.add(cat_listing)

          if cat_listing.public?
            event = Events::CatListingPublished.new(
              cat_id: cat_listing.id,
              slug: cat_listing.slug.value,
              occurred_at: @clock_port.now,
              schema_version: 1
            )
            @event_bus_port.publish(event: event)
          end

          cat_listing
        end
      end

      def update(id:, command:)
        @transaction_port.transaction do
          cat_listing = @cat_listing_repo.find(ValueObjects::CatId.new(value: id))
          raise CatContent::ResourceNotFound unless cat_listing

          new_attrs = cat_listing.attributes.dup
          
          new_attrs[:name] = ValueObjects::CatName.new(value: command.name) if command.name
          new_attrs[:description] = ValueObjects::ContentBlock.new(text: command.description, format: "markdown") if command.description
          new_attrs[:price] = ValueObjects::Money.new(amount_cents: command.price_cents, currency: cat_listing.price.currency) if command.price_cents
          new_attrs[:tags] = ValueObjects::TagList.new(values: command.tags) if command.tags
          new_attrs[:profile] = ValueObjects::CatProfile.new(**command.profile.transform_keys(&:to_sym)) if command.profile
          new_attrs[:media] = ValueObjects::CatMedia.new(**command.media.transform_keys(&:to_sym)) if command.media

          updated_cat_listing = Aggregates::CatListing.new(**new_attrs)
          
          @cat_listing_repo.update(updated_cat_listing)
          
          updated_cat_listing
        end
      end

      def publish(id:)
        @transaction_port.transaction do
          cat_listing = @cat_listing_repo.find(ValueObjects::CatId.new(value: id))
          raise CatContent::ResourceNotFound unless cat_listing

          published_cat = cat_listing.publish
          @cat_listing_repo.update(published_cat)

          event = Events::CatListingPublished.new(
            cat_id: published_cat.id,
            slug: published_cat.slug.value,
            occurred_at: @clock_port.now,
            schema_version: 1
          )
          @event_bus_port.publish(event: event)

          published_cat
        end
      end

      def archive(id:)
        @transaction_port.transaction do
          cat_listing = @cat_listing_repo.find(ValueObjects::CatId.new(value: id))
          raise CatContent::ResourceNotFound unless cat_listing

          archived_cat = cat_listing.archive
          @cat_listing_repo.update(archived_cat)

          event = Events::CatListingArchived.new(
            cat_id: archived_cat.id,
            occurred_at: @clock_port.now,
            schema_version: 1
          )
          @event_bus_port.publish(event: event)

          archived_cat
        end
      end
    end
  end
end

