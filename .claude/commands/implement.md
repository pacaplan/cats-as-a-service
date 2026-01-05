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

### 2.1 Domain Layer (`app/domain/{context}/`)
- Aggregates and entities with business invariants
- Value objects for immutable concepts
- Domain events (past tense naming)
- Repository ports (interfaces only)
- Domain services for cross-aggregate logic

### 2.2 Application Layer (`app/application/{context}/`)
- Application services (use cases) that orchestrate domain logic
- Commands and queries as DTOs
- Return `Rampart::Support::Result` from services
- Publish domain events after successful operations

### 2.3 Infrastructure Layer (`app/infrastructure/{context}/`)
- Repository implementations in `persistence/`
- Mappers to translate between domain and ActiveRecord
- Container wiring in `wiring/container.rb`
- Any external adapters needed

### 2.4 Controllers (`app/controllers/`)
- Thin controllers that only call application services
- Never call repositories or domain objects directly
- Handle HTTP concerns (params, responses, status codes)

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

## Phase 5: Validate

Execute validation checks to gather comprehensive feedback.

**Check Agent Capabilities:**
- If **subagents** are available (e.g., Claude Code), run these 4 tasks in parallel using subagents.
- If **subagents** are NOT available, run these 4 tasks serially (one after another) in the main agent.

### Validation Tasks:

**1. Specs:**
Run all existing RSpec tests in the engine and report any failures.
```bash
cd engines/{context} && bundle exec rspec
```

**2. Packwerk:**
Run packwerk check for the engine and report any layer boundary violations.
```bash
./scripts/check-packwerk.sh {context}
```

**3. Rampart Review:**
Spawn the `rampart-reviewer` agent with task: "Review code changes for hexagonal architecture adherence. Scope: all commits in current branch divergent from origin/main. Use `git diff origin/main...HEAD` to identify changed files." If you are not able to directly invoke this agent, run the instructions in Refer directly to `.claude/agents/rampart-reviewer/AGENT.md`.

**4. Code Review:**
Spawn the `code-reviewer` agent with task: "Review code changes for bugs and quality issues. Scope: all commits in current branch divergent from origin/main. Use `git diff origin/main...HEAD` to identify changed files." If you are not able to directly invoke this agent, run the instructions in Refer directly to `.claude/agents/code-reviewer/AGENT.md`.

**Output:** Collect all failures, violations, and review findings from all tasks.

---

## Phase 6: Fix Loop

Address all issues identified by Phase 5 subagents.

**Loop:**
1. Review all feedback from specs, packwerk, and reviewers
2. Fix identified issues (code changes, architecture fixes, bug fixes)
3. **Commit changes** after all issues are fixed
4. **Re-run Phase 5** (run all validation tasks again, using subagents if available)
5. If any failures remain, repeat from step 1
6. Exit loop when all checks pass

**Max iterations:** 5 (to prevent infinite loops). If still failing after 5 iterations, stop and report remaining issues for manual intervention.

---

## Phase 7: New Specs

After all existing checks pass, add new specs for the implemented feature.

**Write specs following the layer structure:**
- `spec/domain/` - Pure Ruby tests, no Rails
- `spec/application/` - Service tests with stubbed ports
- `spec/infrastructure/` - Integration tests with database
- `spec/requests/` - Full API integration tests

**Test isolation from seeded data:**
The test database contains seeded data. To avoid conflicts:
- Use unique identifiers in factories (e.g., `slug: "test-#{SecureRandom.hex(4)}"`)
- Don't assert exact counts when seeded data may exist
- Use `let!` with dynamic values rather than hardcoded slugs/names

**Run new specs to verify they pass:**
```bash
cd engines/{context} && bundle exec rspec
```

**Commit changes** after phase 7 is complete.

---

## Phase 8: Lint (StandardRB)

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

**Commit changes** after phase 8 is complete.

---

## Completion Checklist

Before marking complete, verify:
- [ ] Database migrations applied successfully
- [ ] All three hexagonal layers implemented
- [ ] Frontend components working
- [ ] Manual UI testing passed (Phase 4)
- [ ] All existing specs passing
- [ ] Packwerk check passing
- [ ] Both reviewers provided feedback with no remaining issues
- [ ] New specs written and passing
- [ ] StandardRB linting passing
- [ ] All changes committed
- [ ] Opened a pull request to `main` using GitHub CLI (`gh pr create --base main`)
