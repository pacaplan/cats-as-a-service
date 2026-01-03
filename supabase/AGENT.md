# Supabase Database Guide

## Overview

This project uses Supabase for local PostgreSQL development. The database runs in Docker containers managed by the Supabase CLI.

## Starting Supabase

Before running the API or tests, ensure Supabase is running:

```bash
npx supabase start
```

This will:
- Start all required Docker containers
- Apply all migrations in `supabase/migrations/`
- Display connection URLs and credentials

## Stopping Supabase

```bash
npx supabase stop
```

Add `--no-backup` to skip creating a backup:

```bash
npx supabase stop --no-backup
```

## Applying Migrations

Migrations are automatically applied when running `supabase start`. To apply new migrations without restarting:

```bash
npx supabase migration up
```

To reset the database and reapply all migrations:

```bash
npx supabase db reset
```

**Warning:** `db reset` will delete all data.

## Migration File Naming

Create migrations in `supabase/migrations/` with this naming convention:

```
YYYYMMDDHHMMSS_descriptive_name.sql
```

Example: `20250104000001_add_lockable_to_shopper_identities.sql`

## Container Conflicts

If you see errors like:

```
The container name "/supabase_*_rampart" is already in use
```

This means another Supabase instance is running (possibly from a different project). To resolve:

1. Stop all Supabase instances:
   ```bash
   npx supabase stop --no-backup
   ```

2. If containers persist, manually remove them:
   ```bash
   docker ps -a | grep supabase | awk '{print $1}' | xargs docker rm -f
   ```

3. Restart Supabase:
   ```bash
   npx supabase start
   ```

## Test Database

**Important:** The test and development environments share the same Supabase database.

This means:
- Data created during manual testing persists across test runs
- RSpec tests may fail if duplicate data exists (e.g., unique email constraints)
- Always use unique identifiers in test fixtures (e.g., `SecureRandom.hex`)

### Cleaning Test Data

To remove specific test data:

```bash
docker exec supabase_db_rampart psql -U postgres -d postgres -c "DELETE FROM schema.table WHERE condition;"
```

Example:
```bash
docker exec supabase_db_rampart psql -U postgres -d postgres -c "DELETE FROM identity.shopper_identities WHERE email = 'test@example.com';"
```

### Inspecting the Database

Connect via psql:

```bash
docker exec -it supabase_db_rampart psql -U postgres -d postgres
```

List tables in a schema:

```sql
\dt identity.*
```

Describe a table:

```sql
\d identity.shopper_identities
```

## Connection Details

After `supabase start`, the database is available at:

- **Host:** `localhost`
- **Port:** `54322`
- **User:** `postgres`
- **Password:** `postgres`
- **Database:** `postgres`

Connection string:
```
postgresql://postgres:postgres@localhost:54322/postgres
```

## Troubleshooting

### "relation already exists" during migration

The migration tracking may be out of sync. Run:

```bash
npx supabase db reset
```

### Container health check failures

Some containers (like `realtime`) may show as unhealthy but the database still works. Check if the database container is running:

```bash
docker ps | grep supabase_db
```

### Port conflicts

If port 54322 is in use, check for orphaned containers:

```bash
docker ps -a | grep 54322
```
