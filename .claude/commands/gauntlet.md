---
description: Run the full verification gauntlet
allowed-tools: Bash
---
# /gauntlet
Execute the autonomous verification suite.

1. Run `~/paul/agent-gauntlet/bin/agent-gauntlet`.
2. If it fails, read the log files in `.gauntlet_logs/` to understand exactly what went wrong.
3. Fix any code or logic errors found by the tools or AI reviewers.
4. If you disagree with AI reviewer feedback, briefly explain your reasoning in the code comments rather than ignoring it silently.
5. Re-run `/gauntlet` until it passes, or ask the human how to proceed if you disagree with remaining failures.