# Implement Feature Command

Execute a complete vertical slice implementation for: **$ARGUMENTS**

> ⚠️ **Single Engine Scope:** Each vertical slice must be implemented within a single engine. If the requirements necessitate changes across multiple engines (e.g., both `cat_content` and `identity`), **HALT and request human guidance** before proceeding.

> 📖 **Database Guide:** See `supabase/AGENT.md` for detailed Supabase setup, troubleshooting, and database management instructions.

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

## Phase 0: Branching & Database Setup

### 0.1 Branching

Before starting, check for uncommitted changes. If any exist, pause and request user input before proceeding.

Ensure work is on a feature branch. If the current branch is `main`, check out a new feature branch.

### 0.2 Database Setup

Verify Supabase is running and the database is ready:

```bash
npx supabase status
```

If Supabase is not running or shows errors:

1. Stop any existing instances (resolves container conflicts):
   ```bash
   npx supabase stop --no-backup
   ```

2. Start Supabase (applies all migrations automatically):
   ```bash
   npx supabase start
   ```

**Note:** Test and development share the same database. Clean up any stale test data if needed before running specs.

### 0.3 API Server Setup

Verify the Rails API is running:

```bash
curl -s http://localhost:8000/api/catalog | head -c 100
```

If not running, start it:

```bash
./scripts/start_api.sh
```

Wait for startup, then verify with a health check:

```bash
curl -s http://localhost:8000/api/catalog
```

The API should return a JSON response with catalog listings.

### 0.4 Web App Setup

Verify the Next.js web app is running:

```bash
curl -s http://localhost:3000 | head -c 100
```

If not running, start it:

```bash
./scripts/start_web.sh
```

The web app should be accessible at `http://localhost:3000`.

---

## Phase 1: Database

Create Supabase migrations in `supabase/migrations/`.

**Steps:**
1. Design the database schema changes needed for this feature
2. Create timestamped migration files following Supabase conventions
3. Include both `up` and `down` migrations
4. Consider indexes, constraints, and foreign keys

**Naming:** `YYYYMMDDHHMMSS_descriptive_name.sql`

**Commit changes** After phase 1 is complete.

---

## Phase 2: Rails (Backend)

Implement the hexagonal architecture layers in the appropriate engine under `engines/`.

> 🤖 **Rampart Guidance:** Use the rampart skill for general guidance implementing all Rails code (`.claude/skills/rampart/SKILL.md`).
> 🤖 **Engine Guidance:** Consult `engines/{context}/AGENTS.md` for engine-specific instructions if it exists.

**Layer Order:**

### 2.1 TDD: Write Request Specs First

Before implementing any code, write request specs covering all acceptance criteria and error cases from the capability spec.

**Focus on behavior-driven request specs:**
- Write specs for each acceptance criterion in the spec file
- Cover all error handling scenarios (404, 503, validation errors, etc.)
- Test the end-to-end API response flow
- Only add domain/application/infrastructure layer specs when specifically needed for complex logic

**Run specs to confirm they fail (red phase):**
```bash
cd engines/{context} && bundle exec rspec spec/requests/
```

All specs should fail at this point since no implementation exists yet.

### 2.2 Domain Layer (`app/domain/{context}/`)
- Aggregates and entities with business invariants
- Value objects for immutable concepts
- Domain events (past tense naming)
- Repository ports (interfaces only)
- Domain services for cross-aggregate logic

### 2.3 Application Layer (`app/application/{context}/`)
- Application services (use cases) that orchestrate domain logic
- Commands and queries as DTOs
- Return `Rampart::Support::Result` from services
- Publish domain events after successful operations

### 2.4 Infrastructure Layer (`app/infrastructure/{context}/`)
- Repository implementations in `persistence/`
- Mappers to translate between domain and ActiveRecord
- Container wiring in `wiring/container.rb`
- Any external adapters needed

### 2.5 Controllers (`app/controllers/`)
- Thin controllers that only call application services
- Never call repositories or domain objects directly
- Handle HTTP concerns (params, responses, status codes)

### 2.6 Run Specs (Green Phase)

Run the request specs written in Phase 2.1 to verify the implementation:
```bash
cd engines/{context} && bundle exec rspec spec/requests/
```

All specs should now pass. If any fail, fix the implementation and re-run until green.

### 2.7 Refactor (Optional)

With passing specs as a safety net, consider if any refactoring would improve the code.

**When to refactor:**
- Duplicated logic that could be extracted
- Long methods that should be split
- Unclear naming that could be improved
- Missed opportunities to use existing abstractions

**Keep it light:** Only refactor if there's clear value. Re-run specs after any changes to ensure nothing broke.

**Key Rules:**
- Domain and Application layers must be pure Ruby (no Rails)
- All classes use flat namespace: `{Context}::ClassName`
- Inherit from appropriate Rampart base classes

**Commit changes** After phase 2 is complete.

---

## Phase 3: Frontend

Build Next.js components and pages in `apps/web/`.

**Steps:**
1. Create/update components in `apps/web/src/components/`
2. Add/update pages in `apps/web/src/app/`
3. Implement API integration with the Rails backend
4. Add appropriate loading and error states
5. Ensure responsive design

**Commit changes** After phase 3 is complete.

---

## Phase 4: Playwright (Manual UI Testing)

Manually test the feature in the browser using Playwright MCP tools. This is hands-on verification, not running an automated test suite.

**Steps:**
1. Use MCP browser tools to navigate to the feature
2. Interact with the UI to verify the feature works correctly
3. If something fails, analyze and fix the issue (frontend or backend)
4. Re-test the fix
5. Repeat up to 3 times if issues persist

**After 3 failures:** Stop and report the issue for manual intervention.

**Commit changes** After phase 4 is complete.

---

## Phase 5: Supplementary Specs

After implementation, add specs for other layers where valuable.

**Purpose:** Fill in coverage for domain, application, and infrastructure layers where unit/integration tests provide value beyond the request specs written in Phase 2.1.

**Guidance:**
- Full spec coverage is NOT required—focus on maintainable, non-brittle specs
- Prioritize specs for complex business logic in domain/application layers
- Avoid over-testing simple pass-through code or trivial mappers
- Infrastructure specs should focus on edge cases not covered by request specs

**Layer-specific specs (add as needed):**
- `spec/domain/` - Pure Ruby tests for complex invariants or domain logic
- `spec/application/` - Service tests for orchestration logic with stubbed ports
- `spec/infrastructure/` - Integration tests for repository edge cases

**Run all specs:**
```bash
cd engines/{context} && bundle exec rspec
```

**Commit changes** after phase 5 is complete.

---

## Phase 6: Lint (StandardRB)

Lint all Ruby code in the engine with StandardRB.

**Loop:**

1. Run safe auto-fix:
```bash
cd engines/{context} && bundle exec standardrb --fix
```

2. If violations remain, run unsafe auto-fix and review each change for safety:
```bash
cd engines/{context} && bundle exec standardrb --fix-unsafely
```
Review the diff to ensure unsafe fixes didn't break anything.

3. If violations still remain, manually fix them.

4. Re-run specs to ensure fixes didn't break anything:
```bash
cd engines/{context} && bundle exec rspec
```

5. If specs fail, fix the failures and return to step 1.

6. Exit loop when standardrb passes and all specs pass.

**Max iterations:** 3. If still failing, stop and report remaining issues.

**Commit changes** after phase 6 is complete.

---

## Phase 7: Validate (The Gauntlet)

Execute the autonomous verification suite to gather comprehensive feedback and ensure quality: `@cats-as-a-service/.gauntlet/run_gauntlet.md`.


---

## Phase 8: Fix Loop

Address all issues identified by the Gauntlet.

**Loop:**
1. Read failure logs in `.gauntlet_logs/` (e.g., `gemini.log`, `rspec.log`)
2. Fix identified issues (code changes, architecture fixes, bug fixes)
3. **Commit changes** after all issues are fixed
4. **Re-run Phase 7** (`./scripts/gauntlet.sh`)
5. If any failures remain, repeat from step 1
6. Exit loop when Verification Gauntlet passes

**Max iterations:** 5. If still failing, stop and report.

---

## Completion Checklist

Before marking complete, verify:
- [ ] Database migrations applied successfully
- [ ] All three hexagonal layers implemented
- [ ] Frontend components working
- [ ] Manual UI testing passed (Phase 4)
- [ ] Verification Gauntlet passed
- [ ] All changes committed
- [ ] Opened a pull request to `main` using GitHub CLI (`gh pr create --base main`)
