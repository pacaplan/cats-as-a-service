# Controller Guidelines

## Critical Rule: Controllers Only Call Application Services

Controllers are **primary adapters**. They must ONLY invoke application services—never repositories or domain objects directly.

### ✅ Correct Pattern

```ruby
def archive
  result = cat_service.archive(id: params[:id])
  render json: serialize(result.value)
end
```

### ❌ Prohibited Patterns

```ruby
def archive
  # ❌ Never call repositories directly
  cat = cat_repository.find(params[:id])
  
  # ❌ Never call domain methods directly
  updated = cat.archive
  
  # ❌ Never persist through repositories
  cat_repository.update(updated)
end
```

### Why

Bypassing application services breaks:
- Transaction boundaries
- Event publishing
- Business rule orchestration
- Hexagonal architecture
