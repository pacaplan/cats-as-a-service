# RSpec Request Specs for Cat Content Catalog API

## Summary

Add RSpec testing infrastructure to the `cat_content` engine and write request specs for the public catalog endpoints. The specs will test JSON responses and domain events using FactoryBot for test data setup.

## Files to Create/Modify

### 1. Update Engine Gemfile

Modify [engines/cat_content/Gemfile](engines/cat_content/Gemfile) to add testing dependencies:

```ruby
group :development, :test do
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.5"
end
```

### 2. Create RSpec Configuration

**`engines/cat_content/spec/spec_helper.rb`** - Basic RSpec configuration

**`engines/cat_content/spec/rails_helper.rb`** - Rails-specific config including:

- Load engine's application
- Configure FactoryBot
- Set up database cleaner/transactions
- Include domain event test helpers

### 3. Create FactoryBot Factory

**`engines/cat_content/spec/factories/cat_listings.rb`** - Factory for CatListing records with:

- Required attributes: id, name, slug, description, image_url, price_cents, currency, visibility
- Nested profile and media attributes
- Traits for `:published` status

### 4. Create Domain Event Test Support

**`engines/cat_content/spec/support/domain_events.rb`** - Helper to capture and assert domain events fired during requests, leveraging the `Rampart::Domain::AggregateRoot#unpublished_events` pattern.

### 5. Create Request Specs

**`engines/cat_content/spec/requests/catalog_spec.rb`** - Request specs covering:

**`GET /api/catalog`**

- Returns paginated list of published cats
- Asserts JSON structure: `cats[]` with id, name, slug, description, image_url, price, tags
- Asserts meta pagination fields
- Asserts `CatListingViewed` or similar domain event (if applicable)

**`GET /api/catalog/:slug`**

- Returns full cat details for valid slug
- Asserts JSON structure: full cat with profile, media arrays
- Returns 404 for non-existent slug

## Key Implementation Details

- Specs use `type: :request` per RSpec Rails conventions
- FactoryBot creates test data directly in the cat_content schema via `CatContent::Infrastructure::Persistence::BaseRecord`
- JSON assertions use `expect(response.parsed_body)` for response validation
- Domain events captured via test double/spy on the event bus or aggregate unpublished_events

## File Structure

```
engines/cat_content/spec/
├── spec_helper.rb
├── rails_helper.rb
├── factories/
│   └── cat_listings.rb
├── support/
│   └── domain_events.rb
└── requests/
    └── catalog_spec.rb
```