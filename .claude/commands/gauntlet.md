---
description: Run the full verification gauntlet (Tests + Packwerk + Gemini + Codex)
allowed-tools: Bash
---
# /gauntlet
Execute the autonomous verification suite.

1. Run `./scripts/gauntlet.sh`.
2. If it fails, read the log files in `.gauntlet_logs/` to understand exactly what went wrong.
3. Fix any code or logic errors found by the tools or AI reviewers.
4. Re-run `/gauntlet` until it returns a success message.
