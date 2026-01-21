# Project Standards: Autonomous Engineering

## Definition of Done (DoD)
You are not finished with any task until you have fulfilled the following "Gauntlet" protocol:
1. **Implementation**: Complete all requested code changes.
2. **Testing**: Ensure new or modified logic has corresponding RSpec tests.
3. **Verification**: Invoke `@cats-as-a-service/.gauntlet/run_gauntlet.md`.
4. **Autonomous Repair**: If the gauntlet fails (exit code 1), you must:
   - Read the relevant log in `.gauntlet_logs/`.
   - Apply the fix immediately.
   - Repeat `@cats-as-a-service/.gauntlet/run_gauntlet.md` until it passes.

## Reviewer Roles
- **Gemini**: Acts as your architectural senior dev. Look for N+1 queries or Rails-specific anti-patterns.
- **Codex**: Acts as your strict logic gatekeeper. Focuses on race conditions, nil-pointers, and thread safety.

Do not ask the user for permission to fix issues found during the gauntlet. Just fix them and re-verify.
