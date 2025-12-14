# Agent Guidelines for Cats-as-a-Service

## Project Overview

This is a demo application showcasing DDD + Hexagonal Architecture patterns through a cat e-commerce application using the Rampart framework.

### Key Directories

| Path | Technology | Purpose |
|------|------------|---------|
| `apps/web/` | Next.js | Frontend UI for the cat e-commerce app |
| `apps/api/` | Rails | Backend API that mounts bounded context engines |
| `engines/*/` | Rails Engines | Isolated bounded contexts (Catalog, Commerce, Auth) |
| `supabase/` | PostgreSQL | Database migrations and configuration |
| `docs/` | Markdown | Architecture specs and bounded context definitions |

### Framework Dependency

This application depends on the Rampart framework located at `../rampart`:
- Framework repository: https://github.com/pcaplan/rampart
- Local path: `../../rampart` (relative to apps/api and engines/*)

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

### Development Server Startup

```bash
# Start Supabase
supabase start

# Start both servers
scripts/start_dev.sh

# Or individually:
cd apps/api && rails server      # API on :8000
cd apps/web && npm run dev       # Web on :3000
```
