# Rampart Framework + Cat & Content Bounded Context

This document describes the full technical specification for:

1. **Rampart** — a pure-Ruby framework implementing Domain‑Driven Design + Hexagonal Architecture using dry‑rb gems.
2. **Cat & Content Bounded Context Implementation** inside a Rails engine — using Rampart for domain and application layers, and Rails only inside the infrastructure layer.

It includes:
- Directory structure
- Component architecture
- Example implementations
- Rails integration details

---

## 1. Rampart GEM — Architecture and Design

Rampart is a pure-Ruby gem that provides foundational building blocks for creating bounded contexts.

### 1.1 Principles
- **No Rails dependency**
- Built on **dry-types**, **dry-struct**, **dry-container**, **dry-auto_inject**, **dry-monads**
- Provides abstractions for Domain, Application, Ports, Adapters
- Follows Hexagonal Architecture conventions

### 1.2 Directory Structure
```
rampart/
  lib/
    rampart.rb
    rampart/
      domain/
        aggregate_root.rb
        entity.rb
        value_object.rb
        domain_event.rb
        domain_exception.rb
        domain_service.rb
        repository.rb
      application/
        command.rb
        query.rb
        handler.rb
        service.rb
        transaction.rb
      ports/
        primary_port.rb
        secondary_port.rb
      adapters/
        persistence/
          repository_base.rb
      support/
        result.rb
        id.rb
    rampart/version.rb
```

### 1.3 Example Implementations

#### AggregateRoot
```ruby
module Rampart
  module Domain
    class AggregateRoot < Entity
      # Aggregates are immutable. Domain methods return new instances instead of mutating state.
      # Events are published by application services (the imperative shell) after persistence.
      #
      # Example:
      #   def publish
      #     self.class.new(**attributes.merge(visibility: Visibility.public))
      #   end
    end
  end
end
```

#### Repository Interface
```ruby
module Rampart
  module Domain
    class Repository
      def add(_)  = raise NotImplementedError
      def find(_) = raise NotImplementedError
      def remove(_) = raise NotImplementedError
    end
  end
end
```

#### Domain Exception
```ruby
module Rampart
  module Domain
    class DomainException < StandardError
      attr_reader :code, :context

      def initialize(message, code: nil, context: {})
        @code = code
        @context = context
        super(message)
      end
    end
  end
end
```

Example domain-specific exceptions:
```ruby
module Catalog
  module Exceptions
    class CatAlreadyListedError < Rampart::Domain::DomainException
      def initialize(cat_id)
        super(
          "Cat #{cat_id} is already listed",
          code: :cat_already_listed,
          context: { cat_id: cat_id }
        )
      end
    end

    class InvalidSlugError < Rampart::Domain::DomainException
      def initialize(slug, reason:)
        super(
          "Invalid slug '#{slug}': #{reason}",
          code: :invalid_slug,
          context: { slug: slug, reason: reason }
        )
      end
    end
  end
end
```

#### Command / Query
```ruby
module Rampart
  module Application
    class Command
      def initialize(**attrs)
        attrs.each { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    class Query
      def initialize(**attrs)
        attrs.each { |k, v| instance_variable_set("@#{k}", v) }
      end
    end
  end
end
```

#### Transaction Boundary
```ruby
module Rampart
  module Application
    class Transaction
      def initialize(adapter)
        @adapter = adapter
      end

      def call(&block)
        @adapter.call(&block)
      end
    end
  end
end
```

#### Domain Event (with Versioning)
```ruby
require "dry-struct"
require "securerandom"

module Rampart
  module Domain
    class DomainEvent < Dry::Struct
      # Schema version enables event evolution without breaking consumers.
      # Increment when adding/removing/renaming attributes.
      SCHEMA_VERSION = 1

      attribute :event_id, Types::String.default { SecureRandom.uuid }
      attribute :occurred_at, Types::Time.default { Time.now }
      attribute :schema_version, Types::Integer.default { self::SCHEMA_VERSION }

      def event_type
        self.class.name
      end
    end
  end
end
```

Example versioned domain event:
```ruby
module Catalog
  module Events
    class CatListed < Rampart::Domain::DomainEvent
      SCHEMA_VERSION = 1

      attribute :cat_id, Types::String
      attribute :name, Types::String
      attribute :listed_at, Types::Time.default { Time.now }
    end

    # Example: V2 adds a new field without breaking existing consumers
    class CatListedV2 < Rampart::Domain::DomainEvent
      SCHEMA_VERSION = 2

      attribute :cat_id, Types::String
      attribute :name, Types::String
      attribute :slug, Types::String          # New in V2
      attribute :listed_by, Types::String.optional  # New in V2
      attribute :listed_at, Types::Time.default { Time.now }
    end
  end
end
```

#### Primary & Secondary Ports
```ruby
module Rampart
  module Ports
    module PrimaryPort; end
    module SecondaryPort; end
  end
end
```

---

# 2. Rails Engine — Cat & Content Bounded Context

The Rails engine uses `app/domain`, `app/application`, `app/infrastructure`.

Rails is **only allowed in infrastructure**.

## 2.1 Directory Layout
```
engines/cat_content/
  app/
    controllers/
      cat_listings_controller.rb
      custom_cats_controller.rb
      health_controller.rb

    models/
      cat_listing_record.rb
      custom_cat_record.rb
      prompt_template_record.rb

    domain/
      cat_content/
        aggregates/
          cat_listing.rb
          custom_cat.rb
        entities/
          cat_profile.rb
        value_objects/
          cat_id.rb
          custom_cat_id.rb
          cat_name.rb
          slug.rb
          tag_list.rb
          trait_set.rb
          visibility.rb
          content_block.rb
          cat_media.rb
          cat_prompt.rb
          cat_story.rb
          money.rb
        events/
          cat_listing_published.rb
          cat_listing_archived.rb
          custom_cat_created.rb
          custom_cat_archived.rb
          cat_description_regenerated.rb
        services/
          cat_description_policy.rb
          cat_copy_generation_service.rb
          cat_search_specification_factory.rb
          visibility_policy.rb
        ports/
          cat_listing_repository.rb
          custom_cat_repository.rb
          prompt_template_repository.rb
          language_model_port.rb
          search_index_port.rb
          media_storage_port.rb
          slug_generator_port.rb
          clock_port.rb
          id_generator_port.rb
          transaction_port.rb

    application/
      cat_content/
        services/
          cat_listing_service.rb
          custom_cat_service.rb
        commands/
          create_cat_listing_command.rb
          update_cat_listing_command.rb
          generate_custom_cat_command.rb
          archive_custom_cat_command.rb
          regenerate_cat_description_command.rb
        queries/
          list_cat_listings_query.rb
          get_cat_details_query.rb
          list_custom_cats_query.rb

    infrastructure/
      cat_content/
        persistence/
          mappers/
            cat_listing_mapper.rb
            custom_cat_mapper.rb
          repositories/
            sql_cat_listing_repository.rb
            sql_custom_cat_repository.rb
            db_prompt_template_repository.rb
        adapters/
          openai_api_language_model_adapter.rb
          claude_api_language_model_adapter.rb
          search_index_adapter.rb
          s3_media_storage_adapter.rb
          slugify_adapter.rb
          system_clock_adapter.rb
          uuid_id_generator_adapter.rb
          database_transaction_adapter.rb
        http/
          serializers/
            cat_listing_serializer.rb
            custom_cat_serializer.rb
        wiring/
          container.rb
```

---

# 3. Domain Layer (Pure Ruby)

## 3.1 Value Objects

### CatId
```ruby
module CatContent
  module ValueObjects
    class CatId < Rampart::Domain::ValueObject
      attribute :value, Types::String

      def to_s = value

      def ==(other)
        other.is_a?(CatId) && other.value == value
      end
    end
  end
end
```

### CustomCatId
```ruby
module CatContent
  module ValueObjects
    class CustomCatId < Rampart::Domain::ValueObject
      attribute :value, Types::String

      def to_s = value
    end
  end
end
```

### CatName
```ruby
module CatContent
  module ValueObjects
    class CatName < Rampart::Domain::ValueObject
      MAX_LENGTH = 100
      MIN_LENGTH = 1

      attribute :value, Types::String.constrained(
        min_size: MIN_LENGTH,
        max_size: MAX_LENGTH
      )

      def to_s = value
    end
  end
end
```

### Slug
```ruby
module CatContent
  module ValueObjects
    class Slug < Rampart::Domain::ValueObject
      VALID_SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
      MAX_LENGTH = 100

      attribute :value, Types::String.constrained(
        format: VALID_SLUG_PATTERN,
        max_size: MAX_LENGTH
      )

      def self.generate_from(name)
        normalized = name
          .downcase
          .gsub(/[^a-z0-9\s-]/, '')
          .gsub(/\s+/, '-')
          .gsub(/-+/, '-')
          .gsub(/\A-|-\z/, '')
          .slice(0, MAX_LENGTH)

        new(value: normalized)
      end

      def to_s = value
    end
  end
end
```

### TagList
```ruby
module CatContent
  module ValueObjects
    class TagList < Rampart::Domain::ValueObject
      attribute :values, Types::Array.of(Types::String)

      def include?(tag)
        values.include?(tag)
      end

      def to_a = values
    end
  end
end
```

### TraitSet
```ruby
module CatContent
  module ValueObjects
    class TraitSet < Rampart::Domain::ValueObject
      VALID_TRAITS = %i[playful lazy curious friendly independent vocal cuddly adventurous].freeze

      attribute :values, Types::Array.of(Types::Symbol.enum(*VALID_TRAITS))

      def include?(trait)
        values.include?(trait)
      end

      def to_a = values
    end
  end
end
```

### Visibility
```ruby
module CatContent
  module ValueObjects
    class Visibility < Rampart::Domain::ValueObject
      STATES = %i[public private archived].freeze

      attribute :value, Types::Symbol.enum(*STATES)

      def public? = value == :public
      def private? = value == :private
      def archived? = value == :archived

      def to_sym = value
    end
  end
end
```

### ContentBlock
```ruby
module CatContent
  module ValueObjects
    class ContentBlock < Rampart::Domain::ValueObject
      MAX_LENGTH = 5000

      attribute :text, Types::String.constrained(max_size: MAX_LENGTH)

      def to_s = text
    end
  end
end
```

### CatMedia
```ruby
module CatContent
  module ValueObjects
    class CatMedia < Rampart::Domain::ValueObject
      attribute :url, Types::String
      attribute :alt_text, Types::String.optional.default(nil)
      attribute :content_type, Types::String.optional.default(nil)
    end
  end
end
```

### CatPrompt
```ruby
module CatContent
  module ValueObjects
    class CatPrompt < Rampart::Domain::ValueObject
      attribute :text, Types::String
      attribute :quiz_results, Types::Hash.optional.default(nil)

      def to_s = text
    end
  end
end
```

### CatStory
```ruby
module CatContent
  module ValueObjects
    class CatStory < Rampart::Domain::ValueObject
      attribute :text, Types::String
      attribute :generated_at, Types::Time.default { Time.now }

      def to_s = text
    end
  end
end
```

### Money
```ruby
module CatContent
  module ValueObjects
    class Money < Rampart::Domain::ValueObject
      attribute :amount_cents, Types::Integer
      attribute :currency, Types::String.default("USD")

      def formatted
        "$#{format('%.2f', amount_cents / 100.0)} #{currency}"
      end

      def +(other)
        raise ArgumentError, "Currency mismatch" unless currency == other.currency
        self.class.new(amount_cents: amount_cents + other.amount_cents, currency: currency)
      end
    end
  end
end
```

---

## 3.2 Entities

### CatProfile
```ruby
module CatContent
  module Entities
    class CatProfile < Rampart::Domain::Entity
      attribute :id, Types::String
      attribute :age_months, Types::Integer.optional
      attribute :traits, ValueObjects::TraitSet
      attribute :temperament, Types::String.optional
    end
  end
end
```

---

## 3.3 Aggregates

### CatListing
```ruby
module CatContent
  module Aggregates
    class CatListing < Rampart::Domain::AggregateRoot
      attribute :id, ValueObjects::CatId
      attribute :name, ValueObjects::CatName
      attribute :description, ValueObjects::ContentBlock
      attribute :price, ValueObjects::Money
      attribute :slug, ValueObjects::Slug
      attribute :visibility, ValueObjects::Visibility
      attribute :tags, ValueObjects::TagList
      attribute :profile, Entities::CatProfile.optional.default(nil)
      attribute :media, ValueObjects::CatMedia.optional.default(nil)

      def self.create(id:, name:, description:, price:, slug:, tags: nil)
        listing = new(
          id: id,
          name: name,
          description: description,
          price: price,
          slug: slug,
          visibility: ValueObjects::Visibility.new(value: :private),
          tags: tags || ValueObjects::TagList.new(values: [])
        )
        listing
      end

      def publish
        return self if visibility.public?

        self.class.new(**attributes.merge(
          visibility: ValueObjects::Visibility.new(value: :public)
        ))
      end

      def archive
        return self if visibility.archived?

        self.class.new(**attributes.merge(
          visibility: ValueObjects::Visibility.new(value: :archived)
        ))
      end

      def public?
        visibility.public?
      end
    end
  end
end
```

### CustomCat
```ruby
module CatContent
  module Aggregates
    class CustomCat < Rampart::Domain::AggregateRoot
      attribute :id, ValueObjects::CustomCatId
      attribute :user_id, Types::String
      attribute :name, ValueObjects::CatName
      attribute :prompt, ValueObjects::CatPrompt
      attribute :story, ValueObjects::CatStory
      attribute :visibility, ValueObjects::Visibility
      attribute :media, ValueObjects::CatMedia.optional.default(nil)

      def self.create(id:, user_id:, name:, prompt:, story:)
        new(
          id: id,
          user_id: user_id,
          name: name,
          prompt: prompt,
          story: story,
          visibility: ValueObjects::Visibility.new(value: :private)
        )
      end

      def regenerate_story(new_story)
        self.class.new(**attributes.merge(story: new_story))
      end

      def archive
        return self if visibility.archived?

        self.class.new(**attributes.merge(
          visibility: ValueObjects::Visibility.new(value: :archived)
        ))
      end
    end
  end
end
```

---

## 3.4 Domain Events

### CatListingPublished
```ruby
module CatContent
  module Events
    class CatListingPublished < Rampart::Domain::DomainEvent
      SCHEMA_VERSION = 1

      attribute :cat_id, Types::String
      attribute :name, Types::String
      attribute :published_at, Types::Time.default { Time.now }
    end
  end
end
```

### CatListingArchived
```ruby
module CatContent
  module Events
    class CatListingArchived < Rampart::Domain::DomainEvent
      SCHEMA_VERSION = 1

      attribute :cat_id, Types::String
      attribute :archived_at, Types::Time.default { Time.now }
    end
  end
end
```

### CustomCatCreated
```ruby
module CatContent
  module Events
    class CustomCatCreated < Rampart::Domain::DomainEvent
      SCHEMA_VERSION = 1

      attribute :custom_cat_id, Types::String
      attribute :user_id, Types::String
      attribute :name, Types::String
      attribute :created_at, Types::Time.default { Time.now }
    end
  end
end
```

### CustomCatArchived
```ruby
module CatContent
  module Events
    class CustomCatArchived < Rampart::Domain::DomainEvent
      SCHEMA_VERSION = 1

      attribute :custom_cat_id, Types::String
      attribute :archived_at, Types::Time.default { Time.now }
    end
  end
end
```

### CatDescriptionRegenerated
```ruby
module CatContent
  module Events
    class CatDescriptionRegenerated < Rampart::Domain::DomainEvent
      SCHEMA_VERSION = 1

      attribute :cat_id, Types::String
      attribute :regenerated_at, Types::Time
    end
  end
end
```

---

## 3.5 Secondary Ports (Interfaces)

### CatListingRepository
```ruby
module CatContent
  module Ports
    class CatListingRepository < Rampart::Ports::SecondaryPort
      abstract_method :add, :find, :find_by_slug, :list_public, :update, :remove
    end
  end
end
```

### CustomCatRepository
```ruby
module CatContent
  module Ports
    class CustomCatRepository < Rampart::Ports::SecondaryPort
      abstract_method :add, :find, :list_by_user, :list_all, :update, :remove
    end
  end
end
```

### LanguageModelPort
```ruby
module CatContent
  module Ports
    class LanguageModelPort < Rampart::Ports::SecondaryPort
      abstract_method :generate_names, :generate_story, :regenerate_description
    end
  end
end
```

### Other Ports
```ruby
module CatContent
  module Ports
    class MediaStoragePort < Rampart::Ports::SecondaryPort
      abstract_method :upload, :get_url, :delete
    end

    class SearchIndexPort < Rampart::Ports::SecondaryPort
      abstract_method :index, :search, :remove
    end

    class ClockPort < Rampart::Ports::SecondaryPort
      abstract_method :now
    end

    class IdGeneratorPort < Rampart::Ports::SecondaryPort
      abstract_method :generate
    end

    class TransactionPort < Rampart::Ports::SecondaryPort
      abstract_method :call
    end
  end
end
```

---

# 4. Application Layer (Pure Ruby)

## 4.1 Commands

### CreateCatListingCommand
```ruby
module CatContent
  module Commands
    class CreateCatListingCommand < Rampart::Application::Command
      attribute :name, Types::String
      attribute :description, Types::String
      attribute :price_cents, Types::Integer
      attribute :currency, Types::String.default("USD")
      attribute :slug, Types::String.optional
      attribute :tags, Types::Array.of(Types::String).default([].freeze)
    end
  end
end
```

### GenerateCustomCatCommand
```ruby
module CatContent
  module Commands
    class GenerateCustomCatCommand < Rampart::Application::Command
      attribute :user_id, Types::String
      attribute :prompt_text, Types::String
      attribute :quiz_results, Types::Hash.optional.default(nil)
    end
  end
end
```

### ArchiveCustomCatCommand
```ruby
module CatContent
  module Commands
    class ArchiveCustomCatCommand < Rampart::Application::Command
      attribute :custom_cat_id, Types::String
      attribute :user_id, Types::String  # for authorization
    end
  end
end
```

## 4.2 Queries

### ListCatListingsQuery
```ruby
module CatContent
  module Queries
    class ListCatListingsQuery < Rampart::Application::Query
      attribute :tags, Types::Array.of(Types::String).default([].freeze)
      attribute :page, Types::Integer.default(1)
      attribute :per_page, Types::Integer.default(20)
    end
  end
end
```

### ListCustomCatsQuery
```ruby
module CatContent
  module Queries
    class ListCustomCatsQuery < Rampart::Application::Query
      attribute :user_id, Types::String
      attribute :include_archived, Types::Bool.default(false)
    end
  end
end
```

## 4.3 Application Services

### CatListingService
```ruby
module CatContent
  module Services
    class CatListingService < Rampart::Application::Service
      include Import[:cat_listing_repo, :id_generator, :clock, :transaction, :event_bus]

      # [Consumer] Browse/filter Cat-alog
      def list(query)
        cat_listing_repo.list_public(
          tags: query.tags,
          page: query.page,
          per_page: query.per_page
        )
      end

      # [Consumer] Retrieve single cat details
      def get(id)
        cat_listing_repo.find(id) or raise Exceptions::CatNotFoundError.new(id)
      end

      # [Admin] Create a new premade cat
      def create(command)
        transaction.call do
          id = ValueObjects::CatId.new(value: id_generator.generate)
          name = ValueObjects::CatName.new(value: command.name)
          description = ValueObjects::ContentBlock.new(text: command.description)
          price = ValueObjects::Money.new(
            amount_cents: command.price_cents,
            currency: command.currency
          )
          slug = command.slug ?
            ValueObjects::Slug.new(value: command.slug) :
            ValueObjects::Slug.generate_from(command.name)
          tags = ValueObjects::TagList.new(values: command.tags)

          listing = Aggregates::CatListing.create(
            id: id,
            name: name,
            description: description,
            price: price,
            slug: slug,
            tags: tags
          )

          persisted = cat_listing_repo.add(listing)
          event_bus.publish(Events::CatListingCreated.new(cat_listing_id: persisted.id))
          Success(persisted)
        end
      end

      # [Admin] Make cat publicly visible
      def publish(id)
        transaction.call do
          listing = cat_listing_repo.find(id) or raise Exceptions::CatNotFoundError.new(id)
          published = listing.publish
          cat_listing_repo.update(published)
          event_bus.publish(Events::CatListingPublished.new(cat_listing_id: published.id))
          Success(published)
        end
      end

      # [Admin] Remove cat from public view
      def archive(id)
        transaction.call do
          listing = cat_listing_repo.find(id) or raise Exceptions::CatNotFoundError.new(id)
          archived = listing.archive
          cat_listing_repo.update(archived)
          event_bus.publish(Events::CatListingArchived.new(cat_listing_id: archived.id))
          Success(archived)
        end
      end
    end
  end
end
```

### CustomCatService
```ruby
module CatContent
  module Services
    class CustomCatService < Rampart::Application::Service
      include Import[:custom_cat_repo, :language_model, :id_generator, :clock, :transaction, :event_bus]

      # [Consumer] List user's custom cats
      def list(user_id, include_archived: false)
        custom_cat_repo.list_by_user(user_id, include_archived: include_archived)
      end

      # [Consumer] Retrieve single custom cat details
      def get(id)
        custom_cat_repo.find(id) or raise Exceptions::CatNotFoundError.new(id)
      end

      # [Consumer] Create new custom cat via LLM
      def generate(command)
        transaction.call do
          id = ValueObjects::CustomCatId.new(value: id_generator.generate)
          prompt = ValueObjects::CatPrompt.new(
            text: command.prompt_text,
            quiz_results: command.quiz_results
          )

          # Generate name suggestions and story via LLM
          names = language_model.generate_names(prompt)
          story_text = language_model.generate_story(prompt, names.first)
          story = ValueObjects::CatStory.new(text: story_text)
          name = ValueObjects::CatName.new(value: names.first)

          cat = Aggregates::CustomCat.create(
            id: id,
            user_id: command.user_id,
            name: name,
            prompt: prompt,
            story: story
          )

          persisted = custom_cat_repo.add(cat)
          event_bus.publish(Events::CustomCatCreated.new(custom_cat_id: persisted.id, user_id: persisted.user_id))
          Success(persisted)
        end
      end

      # [Consumer] Regenerate AI description
      def regenerate_description(id)
        transaction.call do
          cat = custom_cat_repo.find(id) or raise Exceptions::CatNotFoundError.new(id)
          new_story_text = language_model.regenerate_description(cat.prompt, cat.name)
          new_story = ValueObjects::CatStory.new(text: new_story_text)
          updated = cat.regenerate_story(new_story)
          custom_cat_repo.update(updated)
          event_bus.publish(Events::CatDescriptionRegenerated.new(custom_cat_id: updated.id))
          Success(updated)
        end
      end

      # [Consumer] Archive a custom cat
      def archive(id, user_id:)
        transaction.call do
          cat = custom_cat_repo.find(id) or raise Exceptions::CatNotFoundError.new(id)
          raise Exceptions::UnauthorizedError.new unless cat.user_id == user_id
          archived = cat.archive
          custom_cat_repo.update(archived)
          event_bus.publish(Events::CustomCatArchived.new(custom_cat_id: archived.id, user_id: archived.user_id))
          Success(archived)
        end
      end

      # [Admin] List all custom cats for moderation
      def list_all(query)
        custom_cat_repo.list_all(
          page: query.page,
          per_page: query.per_page
        )
      end

      private

      # Side effects (event publishing, persistence) stay in the application layer.
    end
  end
end
```

---

# 5. Infrastructure Layer (Rails-Only)

## 5.1 ActiveRecord Models

```ruby
# app/models/cat_listing_record.rb
class CatListingRecord < ApplicationRecord
  self.table_name = "cat_listings"
end

# app/models/custom_cat_record.rb
class CustomCatRecord < ApplicationRecord
  self.table_name = "custom_cats"
end
```

## 5.2 Mapper

```ruby
module CatContent
  module Infrastructure
    module Persistence
      class CatListingMapper
        def to_domain(record)
          profile = if record.age_months || record.traits&.any? || record.temperament
            Entities::CatProfile.new(
              id: record.id,
              age_months: record.age_months,
              traits: ValueObjects::TraitSet.new(values: (record.traits || []).map(&:to_sym)),
              temperament: record.temperament
            )
          else
            nil
          end

          Aggregates::CatListing.new(
            id: ValueObjects::CatId.new(value: record.id),
            name: ValueObjects::CatName.new(value: record.name),
            description: ValueObjects::ContentBlock.new(text: record.description),
            price: ValueObjects::Money.new(
              amount_cents: record.price_cents,
              currency: record.currency
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
          CatListingRecord.find_or_initialize_by(id: aggregate.id.to_s).tap do |r|
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
              r.traits = aggregate.profile.traits.to_a.map(&:to_s)
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
```

## 5.3 Repository Implementation

```ruby
module CatContent
  module Infrastructure
    module Persistence
      class SqlCatListingRepository < Ports::CatListingRepository
        def initialize(mapper: CatListingMapper.new)
          @mapper = mapper
        end

        def add(aggregate)
          rec = @mapper.to_record(aggregate)
          rec.save!
          aggregate
        end

        def find(id)
          rec = CatListingRecord.find_by(id: id.to_s)
          rec && @mapper.to_domain(rec)
        end

        def find_by_slug(slug)
          rec = CatListingRecord.find_by(slug: slug.to_s)
          rec && @mapper.to_domain(rec)
        end

        def list_public(tags: [], page: 1, per_page: 20)
          scope = CatListingRecord.where(visibility: "public")
          scope = scope.where("tags && ARRAY[?]::varchar[]", tags) if tags.any?
          scope.order(created_at: :desc)
               .offset((page - 1) * per_page)
               .limit(per_page)
               .map { |r| @mapper.to_domain(r) }
        end

        def update(aggregate)
          add(aggregate)  # find_or_initialize handles upsert
        end

        def remove(id)
          CatListingRecord.where(id: id.to_s).delete_all
        end
      end
    end
  end
end
```

## 5.4 Adapter Implementations

### OpenAI Language Model Adapter
```ruby
module CatContent
  module Infrastructure
    module Adapters
      class OpenAIApiLanguageModelAdapter < Ports::LanguageModelPort
        def initialize(client: OpenAI::Client.new)
          @client = client
        end

        def generate_names(prompt)
          response = @client.chat(
            model: "gpt-4",
            messages: [{ role: "user", content: names_prompt(prompt) }]
          )
          parse_names(response)
        end

        def generate_story(prompt, name)
          response = @client.chat(
            model: "gpt-4",
            messages: [{ role: "user", content: story_prompt(prompt, name) }]
          )
          response.dig("choices", 0, "message", "content")
        end

        def regenerate_description(prompt, name)
          generate_story(prompt, name)
        end

        private

        def names_prompt(prompt)
          "Generate 3 creative cat names based on: #{prompt.text}"
        end

        def story_prompt(prompt, name)
          "Write a fun description for a cat named #{name} based on: #{prompt.text}"
        end

        def parse_names(response)
          content = response.dig("choices", 0, "message", "content")
          content.split("\n").map(&:strip).reject(&:empty?).first(3)
        end
      end
    end
  end
end
```

### Other Adapters
```ruby
module CatContent
  module Infrastructure
    module Adapters
      class SystemClockAdapter < Ports::ClockPort
        def now
          Time.current
        end
      end

      class UuidIdGeneratorAdapter < Ports::IdGeneratorPort
        def generate
          SecureRandom.uuid
        end
      end

      class DatabaseTransactionAdapter < Ports::TransactionPort
        def call(&block)
          ActiveRecord::Base.transaction(&block)
        end
      end
    end
  end
end
```

## 5.5 Serializers

```ruby
module CatContent
  module Infrastructure
    module HTTP
      class CatListingSerializer
        def initialize(cat_listing)
          @cat = cat_listing
        end

        def as_json
          result = {
            id: @cat.id.to_s,
            name: @cat.name.to_s,
            description: @cat.description.to_s,
            slug: @cat.slug.to_s,
            price: {
              amount_cents: @cat.price.amount_cents,
              currency: @cat.price.currency
            },
            tags: @cat.tags.to_a,
            visibility: @cat.visibility.to_sym.to_s,
            image_url: @cat.media&.url,
            image_alt: @cat.media&.alt_text
          }
          
          # Include profile if present
          if @cat.profile
            result[:profile] = {
              age_months: @cat.profile.age_months,
              temperament: @cat.profile.temperament,
              traits: @cat.profile.traits.to_a.map(&:to_s)
            }
          end
          
          result
        end
      end
    end
  end
end
```

## 5.6 Rails Controller

```ruby
module CatContent
  module Infrastructure
    module HTTP
      class CatListingsController < ApplicationController
        def index
          query = Queries::ListCatListingsQuery.new(
            tags: parse_tags(params[:tags]),
            page: params[:page]&.to_i || 1
          )
          @cats = cat_listing_service.list(query)
          render json: @cats.map { |c| CatListingSerializer.new(c).as_json }
        end

        def show
          id = ValueObjects::CatId.new(value: params[:id])
          @cat = cat_listing_service.get(id)
          render json: CatListingSerializer.new(@cat).as_json
        rescue Exceptions::CatNotFoundError
          render json: { error: "Cat not found" }, status: :not_found
        end

        def create
          command = Commands::CreateCatListingCommand.new(
            name: params[:name],
            description: params[:description],
            price_cents: params[:price_cents].to_i,
            currency: params[:currency] || "USD",
            slug: params[:slug],
            tags: parse_tags(params[:tags])
          )
          result = cat_listing_service.create(command)

          if result.success?
            render json: CatListingSerializer.new(result.value!).as_json, status: :created
          else
            render json: { error: result.failure.message }, status: :unprocessable_entity
          end
        end

        private

        def cat_listing_service
          Container.resolve(:cat_listing_service)
        end

        def parse_tags(tags_param)
          return [] if tags_param.nil? || tags_param.empty?
          return tags_param if tags_param.is_a?(Array)
          tags_param.split(',').map(&:strip).reject(&:empty?)
        end
      end
    end
  end
end
```

## 5.7 Dependency Container

The bounded context uses `dry-container` for dependency registration and `dry-auto_inject` for 
automatic dependency injection. Services declare their dependencies via `include Import[...]` 
and the container handles all wiring automatically.

```ruby
module CatContent
  class Container
    extend Dry::Container::Mixin

    # Infrastructure adapters
    register(:clock) { Infrastructure::Adapters::SystemClockAdapter.new }
    register(:id_generator) { Infrastructure::Adapters::UuidIdGeneratorAdapter.new }
    register(:transaction) { Infrastructure::Adapters::DatabaseTransactionAdapter.new }
    register(:event_bus) { Rails.configuration.event_bus }
    register(:language_model) { Infrastructure::Adapters::OpenAIApiLanguageModelAdapter.new }

    # Repositories
    register(:cat_listing_repo) { Infrastructure::Persistence::SqlCatListingRepository.new }
    register(:custom_cat_repo) { Infrastructure::Persistence::SqlCustomCatRepository.new }

    # Application services (auto-inject handles dependency wiring)
    register(:cat_listing_service) { Services::CatListingService.new }
    register(:custom_cat_service) { Services::CustomCatService.new }
  end

  # Import mixin for automatic dependency injection
  Import = Dry::AutoInject(Container)
end
```

---

# END OF TECHNICAL SPEC
