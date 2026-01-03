# Cats-as-a-Service Project Rules

## Project Overview

AI-powered custom cat generation and premade cat catalog application using DDD + Hexagonal Architecture via the Rampart framework.

| Directory | Technology | Purpose |
|-----------|------------|---------|
| `apps/web/` | Next.js | Frontend UI for the cat e-commerce app |
| `apps/api/` | Rails | Backend API that mounts bounded context engines |
| `engines/*/` | Rails Engines | Isolated bounded contexts (cat_content, identity) |
| `supabase/` | PostgreSQL | Database migrations and configuration |
| `architecture/` | JSON | System and context architecture blueprints |
| `docs/` | Markdown | Architecture specs and context definitions |

### Bounded Contexts

- **cat_content** - Cat listings, catalog management, content display
- **identity** - User authentication and identity management

### Framework Dependency

This application depends on the Rampart framework located at `../rampart`:
- Framework repository: https://github.com/pcaplan/rampart
- Local path: `../../rampart` (relative to apps/api and engines/*)

---

## Vertical Slice Workflow

Implement features as complete vertical slices following this phase order:

```
Database → Rails → Frontend → Playwright → Specs → Review
```

Use `/implement <feature>` to execute the full workflow. See [`.claude/commands/implement.md`](.claude/commands/implement.md) for detailed phase instructions.

---

## Architecture Blueprints

Architecture is defined in JSON blueprints:
- `architecture/system.json` - System-level configuration and engine registry
- `architecture/cat_content.json` - Cat content context architecture
- `architecture/identity.json` - Identity context architecture

When implementing features, consult these blueprints for:
- Aggregate definitions and invariants
- Domain event schemas
- Port interfaces and expected adapters

---

## Development Commands

```bash
# Start development environment
supabase start
scripts/start_dev.sh

# Or individually:
cd apps/api && rails server      # API on :8000
cd apps/web && npm run dev       # Web on :3000

# Run specs
cd apps/api && bundle exec rspec
cd engines/cat_content && bundle exec rspec

# Run architecture fitness tests
cd engines/cat_content && bundle exec rspec spec/architecture_spec.rb
```

---

## Key Conventions

1. **Hexagonal Architecture** - Domain and Application layers are pure Ruby with no Rails dependencies
2. **Flat Namespaces** - Use `CatContent::CatListing`, not `CatContent::Domain::Aggregates::CatListing`
3. **Repository Pattern** - All persistence goes through repository ports
4. **Domain Events** - Use events for cross-context communication
5. **Application Services** - Controllers only call application services, never repositories directly
6. **Result Objects** - Services return `Rampart::Support::Result` (Success/Failure)

---

## Code Quality

### Before Committing

1. Ensure all tests pass
2. Check for linting errors
3. Verify UI changes in browser when applicable

### Documentation

- Update relevant docs in `docs/` when changing architecture
- Keep README files current in each app/engine
- Document public APIs and important design decisions

---

## Common Tasks

### Creating a new plan document

Before starting a non-trivial task, create a plan document in `docs/plans/`:

1. Find the next available number by checking existing files (e.g., `01-`, `02-`, `03-`)
2. Create a new file following the naming convention: `XX-short-description.md`
3. Include sections for: Scope, Tech Stack, Directory Structure, Key Implementation Details
4. Reference relevant mockups or specs from `docs/cat_app/`

**Examples:**
- `01-ui-prototype-catalog.md`
- `02-ui-prototype-cart-checkout-faq.md`
- `03-ui-prototype-catbot.md`

---

## Review Agents

After implementation, spawn these agents for code review:

- **rampart-reviewer** - Checks hexagonal architecture adherence, layer boundaries, Rampart patterns
- **code-reviewer** - Checks for bugs, security issues, error handling, performance

---

## Related Documentation

- `docs/` - Architecture specs and implementation details
- `docs/plans/` - Implementation plan documents
- Framework: Rampart (`../rampart`)
