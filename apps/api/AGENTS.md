# Rails API Agent Guidelines

## ⚠️ CRITICAL: Follow Implementation Instructions Exactly

When executing the `/implement` command or any structured workflow:

1. **Follow each phase in order** - Do not skip phases or combine them
2. **Complete each step before proceeding** - If a step fails, investigate and fix before moving on
3. **If stuck, HALT for human input** - Do not guess or skip problematic steps
4. **Manual UI testing is required** - Phase 4 requires actual browser interaction, not just curl commands

If you encounter problems (server errors, connection issues, unexpected behavior):
- First, investigate the root cause (check logs, verify services are running)
- Attempt to fix the issue
- If unsuccessful after reasonable effort, **STOP and ask for human guidance**
- Do NOT skip the phase or mark it as complete

---

## Service Ports (Local Development)

| Service | Port | URL |
|---------|------|-----|
| Rails API | 8000 | http://localhost:8000 |
| Next.js Web | 3000 | http://localhost:3000 |
| Supabase Studio | 54323 | http://localhost:54323 |
| PostgreSQL | 54322 | localhost:54322 |

**Common Mistakes to Avoid:**
- The Rails API runs on port **8000**, NOT 3000
- Port 3000 is the Next.js frontend
- Always verify which port you're testing against

---

## Project Structure

This is the main Rails API application that serves as the host for bounded context engines.

### Key Concepts

1. **Bounded Contexts as Rails Engines** - Each bounded context lives in `engines/` as a mountable Rails engine
2. **Schema Isolation** - Each engine uses its own PostgreSQL schema with restricted search_path
3. **Supabase for Schema Management** - All database schemas/tables are created by Supabase migrations
4. **Pure Domain/Application Layers** - Domain and application code must be pure Ruby (no Rails)
5. **Infrastructure Only in Rails** - Only infrastructure layer (controllers, repos, adapters) uses Rails

## Database Configuration

The app uses local Supabase with PostgreSQL schema isolation:

- **Primary Database**: Uses `public` schema for app-level tables
- **Engine Databases**: Each engine uses its own schema (e.g., `cat_content`)
- **Schema Creation**: Handled by Supabase migrations in `supabase/migrations/`
- **Search Path Restriction**: Each connection only sees its designated schema

### Multi-Database Setup

Each engine has its own database configuration in `config/database.yml`:

```yaml
development:
  primary:
    # Primary app database
    schema_search_path: public
  
  cat_content:
    # Cat & Content engine database
    schema_search_path: cat_content
```

## Working with Engines

### Database Setup for New Bounded Context

> **Note:** Engine generation and initial setup is handled by `rampart init`. See [Rampart Features](../../docs/rampart/rampart_features.md) for details.

After generating a new bounded context engine, configure the database:

1. **Create Supabase migration** in `supabase/migrations/`:
   ```sql
   CREATE SCHEMA IF NOT EXISTS context_name;
   
   -- Create tables in the schema
   CREATE TABLE context_name.your_table (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     -- columns...
   );
   
   GRANT USAGE ON SCHEMA context_name TO postgres;
   GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA context_name TO postgres;
   ```

2. **Add database config:**
   ```yaml
   context_name:
     <<: *supabase_local
     schema_search_path: context_name
   ```

## Common Tasks

```bash
# Start Supabase (creates all schemas)
supabase start

# Reset database (recreates from migrations)
supabase db reset

# Start Rails server
rails server
```

## Architecture Rules

1. **Domain Layer** - Pure Ruby, no Rails dependencies
   - Aggregates, Entities, Value Objects
   - Domain Events, Domain Services
   - Repository Interfaces (Ports)

2. **Application Layer** - Pure Ruby, orchestrates domain
   - Application Services (Use Cases)
   - Commands, Queries
   - No Rails, no database, no HTTP

3. **Infrastructure Layer** - Rails-specific implementations
   - Controllers (Primary Adapters)
   - ActiveRecord Models (Secondary Adapters)
   - Repository Implementations
   - External Service Adapters

## Conventions

- Engine models inherit from engine-specific `BaseRecord`
- Database schemas are managed by Supabase (not Rails migrations)
- All domain/application code is pure Ruby
- Infrastructure code can use Rails
- Each engine is completely isolated from others

## Health Check Endpoints

The API provides health check endpoints for troubleshooting connectivity issues:

### Main Health Endpoint

**Route:** `GET /health`

**Purpose:** Comprehensive health check that aggregates status from all components

**Checks:**
- API service status
- Primary database connectivity
- All mounted engine health statuses
