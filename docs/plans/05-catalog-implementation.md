# Catalog API Hexagonal Vertical Slice

## Overview

Refactor the existing catalog endpoints to follow hexagonal architecture with proper layer separation: Domain (pure Ruby) → Application (pure Ruby) → Infrastructure (Rails).

**Design Docs**: 
1. [docs/cat_app/cat_content_implementation.md](docs/cat_app/cat_content_implementation.md) - You MAY copy code directly from this document but you don't have to if it isn't functionally or technically accurate.
2. Ensure implementation is consistent with docs/cat_app/cat_content_architecture.md

## Files to Create/Modify

### 1. Dependencies

Update [engines/cat_content/Gemfile](engines/cat_content/Gemfile) to add:

- `rampart` gem (path: `../../gems/rampart`)

Update [engines/cat_content/cat_content.gemspec](engines/cat_content/cat_content.gemspec) to add:

- `dry-types`, `dry-struct` dependencies

### 2. Domain Layer (Pure Ruby)

**Value Objects** in `app/domain/cat_content/value_objects/`:

- `cat_id.rb` - Unique identifier wrapper
- `cat_name.rb` - Validated name (1-100 chars)
- `slug.rb` - URL-friendly identifier
- `money.rb` - Price with cents + currency
- `tag_list.rb` - Immutable tag collection
- `visibility.rb` - Enum: public/private/archived
- `content_block.rb` - Description text (max 5000 chars)
- `cat_media.rb` - Image URL + alt text
- `trait_set.rb` - Personality traits

**Entity** in `app/domain/cat_content/entities/`:

- `cat_profile.rb` - Age, traits, temperament

**Aggregate** in `app/domain/cat_content/aggregates/`:

- `cat_listing.rb` - Root aggregate with all value objects

**Port** in `app/domain/cat_content/ports/`:

- `cat_listing_repository.rb` - Abstract interface for persistence

### 3. Application Layer (Pure Ruby)

**Query** in `app/application/cat_content/queries/`:

- `list_cat_listings_query.rb` - Params: tags, page, per_page

**Service** in `app/application/cat_content/services/`:

- `cat_listing_service.rb` - `list(query)` and `get_by_slug(slug)` methods

### 4. Infrastructure Layer (Rails)

**Mapper** in `app/infrastructure/cat_content/persistence/mappers/`:

- `cat_listing_mapper.rb` - Converts between ActiveRecord and domain aggregate

**Repository** in `app/infrastructure/cat_content/persistence/repositories/`:

- `sql_cat_listing_repository.rb` - Implements the port using ActiveRecord

**Serializer** in `app/infrastructure/cat_content/http/serializers/`:

- `cat_listing_serializer.rb` - Converts domain aggregate to JSON

**Container** in `app/infrastructure/cat_content/wiring/`:

- `container.rb` - Dependency injection wiring

**Controller** - Refactor [engines/cat_content/app/controllers/cat_content/catalog_controller.rb](engines/cat_content/app/controllers/cat_content/catalog_controller.rb):

- Use `CatListingService` instead of direct ActiveRecord queries

### 5. Engine Configuration

Update [engines/cat_content/lib/cat_content/engine.rb](engines/cat_content/lib/cat_content/engine.rb):

- Configure autoload paths for domain/application layers
- Initialize container

## Key Implementation Details

The controller will delegate to `CatListingService`:

```ruby
def index
  query = ListCatListingsQuery.new(tags: parse_tags(params[:tags]), page: params[:page]&.to_i || 1, per_page: [params[:per_page]&.to_i || 20, 100].min)
  result = cat_listing_service.list(query)
  render json: { cats: result[:cats].map { |c| CatListingSerializer.new(c).as_json }, meta: result[:meta] }
end
```

The repository implements pagination with total count:

```ruby
def list_public(tags:, page:, per_page:)
  scope = CatListingRecord.where(visibility: "public")
  scope = scope.where("tags && ARRAY[?]::varchar[]", tags) if tags.any?
  total = scope.count
  cats = scope.order(created_at: :desc).offset((page - 1) * per_page).limit(per_page).map { |r| @mapper.to_domain(r) }
  { cats: cats, meta: { page: page, per_page: per_page, total: total } }
end
```

## Definition of Done

The existing request specs in [engines/cat_content/spec/requests/catalog_spec.rb](engines/cat_content/spec/requests/catalog_spec.rb) must continue to pass after the refactoring. No new tests required.