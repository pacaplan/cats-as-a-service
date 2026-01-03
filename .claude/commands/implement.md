# Implement Feature Command

Execute a complete vertical slice implementation for: **$ARGUMENTS**

> ⚠️ **Single Engine Scope:** Each vertical slice must be implemented within a single engine. If the requirements necessitate changes across multiple engines (e.g., both `cat_content` and `identity`), **HALT and request human guidance** before proceeding.

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

## Phase 5: Validate (Parallel Subagents)

Spawn all validation checks in parallel using subagents to gather comprehensive feedback:

### Spawn These 4 Subagents in Parallel:

**1. Specs Subagent:**
Spawn a subagent with task: "Run all existing RSpec tests in the engine and report any failures"
```bash
cd engines/{context} && bundle exec rspec
```

**2. Packwerk Subagent:**
Spawn a subagent with task: "Run packwerk check for the engine and report any layer boundary violations"
```bash
./scripts/check-packwerk.sh {context}
```

**3. Rampart Reviewer Subagent:**
Spawn the `rampart-reviewer` agent with task: "Review code changes for hexagonal architecture adherence. Scope: all commits in current branch divergent from origin/main. Use `git diff origin/main...HEAD` to identify changed files."

**4. Code Reviewer Subagent:**
Spawn the `code-reviewer` agent with task: "Review code changes for bugs and quality issues. Scope: all commits in current branch divergent from origin/main. Use `git diff origin/main...HEAD` to identify changed files."

**Output:** Collect all failures, violations, and review findings from all 4 subagents.

---

## Phase 6: Fix Loop

Address all issues identified by Phase 5 subagents.

**Loop:**
1. Review all feedback from specs, packwerk, and reviewers
2. Fix identified issues (code changes, architecture fixes, bug fixes)
3. **Commit changes** after all issues are fixed
4. **Re-run Phase 5** (spawn all validation subagents again)
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
