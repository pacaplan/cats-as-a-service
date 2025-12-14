# Rampart Rails API

Rails 8 API application implementing Hexagonal Architecture with DDD principles, using local Supabase with PostgreSQL schema isolation.

## Architecture

This application uses:
- **Bounded Contexts as Rails Engines** - Each bounded context is a separate Rails engine
- **Schema Isolation** - Each engine uses its own PostgreSQL schema (managed by Supabase)
- **Rampart Framework** - Pure Ruby DDD building blocks (domain, application, ports/adapters)
- **Local Supabase** - PostgreSQL with separate schemas for each bounded context

## Prerequisites

- Ruby 3.3.6
- Docker Desktop (for local Supabase)
- Supabase CLI

## Setup

1. **Start local Supabase** (from project root):
   ```bash
   supabase start
   ```
   
   This creates all schemas and tables via Supabase migrations. Connection details:
   - **DB URL**: postgresql://postgres:postgres@localhost:54322/postgres
   - **Studio URL**: http://localhost:54323

2. **Install dependencies:**
   ```bash
   cd apps/api
   bundle install
   ```

3. **Configure environment variables:**
   
   Copy the example env file:
   ```bash
   cp .env.example .env.development
   ```
   
   The `.env.development` file is automatically loaded by `dotenv-rails`:
   ```bash
   # .env.development
   FRONTEND_URL=http://localhost:3000
   ```

4. **Start the Rails server:**
   ```bash
   rails server
   ```
   
   API will be available at http://localhost:8000

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `FRONTEND_URL` | CORS allowed origin(s) for the frontend | `http://localhost:3000` (dev only) |

For multiple origins, use comma-separated values:
```bash
FRONTEND_URL=https://app.example.com,https://www.example.com
```

**Note:** In production, `FRONTEND_URL` must be set or the app will fail to start.

> **Note**: Supabase handles all database schema creation via its migrations in `supabase/migrations/`.
> Rails just connects to what Supabase created - no Rails migrations needed.

### Troubleshooting

**Docker Not Running:**
If you see "Cannot connect to Docker daemon":
1. Open Docker Desktop
2. Wait for it to start
3. Run `supabase start` again

**Database Connection Issues:**
1. Verify Supabase is running: `supabase status`
2. Check the port (should be 54322): `lsof -i :54322`
3. Verify `config/database.yml` has correct host/port

**Schema Not Found:**
Run `supabase db reset` to recreate all schemas from migrations.

## Schema Isolation

Each bounded context engine has its own PostgreSQL schema with isolated `search_path`:

| Engine | Schema | Search Path | Tables |
|--------|--------|-------------|--------|
| Primary App | `public` | `public` | App-level tables |
| Cat & Content | `cat_content` | `cat_content` | `cat_listings`, `custom_cats` |

Schemas are created by Supabase migrations in `supabase/migrations/`.

## Bounded Contexts

### Cat & Content (`/catalog`)

Manages the cat catalog and custom cat generation.

- **Engine:** `engines/cat_content`
- **Mount Path:** `/catalog`
- **Schema:** `cat_content`

## Development

```bash
# Start Rails server
rails server

# Access Supabase Studio
open http://localhost:54323

# Run console
rails console
```

## Directory Structure

```
apps/api/
├── app/              # Primary application code
├── config/
│   └── database.yml  # Multi-schema configuration

engines/
└── cat_content/      # Cat & Content bounded context
    ├── app/
    │   ├── domain/            # Pure Ruby domain layer
    │   ├── application/       # Pure Ruby application layer
    │   └── infrastructure/    # Rails-specific infrastructure

gems/
└── rampart/          # DDD framework gem
    └── lib/
        └── rampart/  # Domain, application, and port abstractions

supabase/
└── migrations/      # Source of truth for all database schemas
```

## Testing

(To be added - RSpec configuration)

## Implementation Status

### ✅ Completed
- Rails 8.1.1 API-only application
- Local Supabase with PostgreSQL
- Multi-database configuration with schema isolation
- Cat & Content engine mounted at `/catalog`
- Rampart gem integration
- Kamal deployment configuration

### 🔜 Next Steps
1. Implement domain models (Value Objects, Entities, Aggregates)
2. Implement application services (Use cases)
3. Implement infrastructure adapters (Repositories, Controllers)
4. Add RSpec tests
5. Add remaining bounded contexts (Commerce, Identity)

## Deployment

Deployment is configured using Kamal. See `config/deploy.yml` for configuration.
