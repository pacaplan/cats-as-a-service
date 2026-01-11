#!/bin/bash
# scripts/gauntlet.sh - Parallel Verification Suite

# Ensure we are in the project root
cd "$(dirname "$0")/.."

LOG_DIR=".gauntlet_logs"
mkdir -p "$LOG_DIR"
echo "🚀 Launching Parallel Gauntlet (Logs in $LOG_DIR)..."

# Clear old logs
rm -f "$LOG_DIR"/*.log

# Define directories for Ruby checks
RUBY_DIRS=("apps/api" "engines/cat_content" "engines/identity")

# Function to run StandardRB across all Ruby directories
run_lints() {
  local failed=0
  echo "Starting StandardRB checks..." > "$LOG_DIR/standardrb.log"
  
  for dir in "${RUBY_DIRS[@]}"; do
    if [ -d "$dir" ]; then
      echo ">> Checking $dir" >> "$LOG_DIR/standardrb.log"
      # Run standardrb; we use || true to capture failure but continue to next dir, record status
      (cd "$dir" && bundle exec standardrb) >> "$LOG_DIR/standardrb.log" 2>&1
      if [ $? -ne 0 ]; then
        echo "❌ StandardRB failed in $dir" >> "$LOG_DIR/standardrb.log"
        failed=1
      else
        echo "✅ StandardRB passed in $dir" >> "$LOG_DIR/standardrb.log"
      fi
    else
      echo "⚠️ Directory $dir not found" >> "$LOG_DIR/standardrb.log"
    fi
  done
  return $failed
}

# Function to run RSpec across all Ruby directories
run_specs() {
  local failed=0
  echo "Starting RSpec checks..." > "$LOG_DIR/rspec.log"
  
  for dir in "${RUBY_DIRS[@]}"; do
    if [ -d "$dir" ]; then
      echo ">> Testing $dir" >> "$LOG_DIR/rspec.log"
      (cd "$dir" && bundle exec rspec) >> "$LOG_DIR/rspec.log" 2>&1
      if [ $? -ne 0 ]; then
        echo "❌ RSpec failed in $dir" >> "$LOG_DIR/rspec.log"
        failed=1
      else
        echo "✅ RSpec passed in $dir" >> "$LOG_DIR/rspec.log"
      fi
    fi
  done
  return $failed
}

# 1. Static Checks & Tests (Local CPU)
START_LINT=$(date +%s)
(run_lints) & PID_LINT=$!

START_TEST=$(date +%s)
(run_specs) & PID_TEST=$!

# 2. Packwerk (Architecture)
START_PACKWERK=$(date +%s)
(./scripts/check-packwerk.sh > "$LOG_DIR/packwerk.log" 2>&1) & PID_PACKWERK=$!

# Detect which engines have changes
# Get all changed files from both committed and uncommitted changes
CHANGED_FILES=$(git diff --name-only origin/main...HEAD 2>/dev/null; git diff --name-only 2>/dev/null | sort -u)

# Extract unique engines that have changes
CHANGED_ENGINES=()
for file in $CHANGED_FILES; do
  if [[ $file =~ ^engines/([^/]+)/ ]]; then
    engine="engines/${BASH_REMATCH[1]}"
    # Check if engine is not already in the array
    if [[ ! " ${CHANGED_ENGINES[@]} " =~ " ${engine} " ]]; then
      CHANGED_ENGINES+=("$engine")
    fi
  fi
done

# Get the diff for review
GIT_DIFF=$(git diff origin/main...HEAD 2>/dev/null; git diff 2>/dev/null)

# Build context string for changed engines
ENGINE_CONTEXT=""
if [ ${#CHANGED_ENGINES[@]} -gt 0 ]; then
  for engine in "${CHANGED_ENGINES[@]}"; do
    ENGINE_CONTEXT="$ENGINE_CONTEXT @$engine"
  done
  echo "📦 Reviewing changes in: ${CHANGED_ENGINES[*]}"
else
  echo "⚠️ No engine changes detected, skipping AI reviews"
fi

# 3. Gemini Review (Network - Architectural Context)
# Uses gemini CLI to review changes for Hexagonal Architecture adherence (Rampart)
if [ ${#CHANGED_ENGINES[@]} -gt 0 ]; then
  START_GEMINI=$(date +%s)
  # Build the full prompt with diff
  GEMINI_INPUT=$(cat <<EOF
Review the code DIFF below for Hexagonal Architecture adherence based on the instructions in the prompt file. Only review lines that appear in the DIFF section. The engine context is provided for reference only - do not generate feedback for unchanged code.

---
DIFF:

$GIT_DIFF
EOF
)
  (echo "$GEMINI_INPUT" | gemini -p "@prompts/rampart-review.md$ENGINE_CONTEXT" > "$LOG_DIR/gemini.log" 2>&1) & PID_GEMINI=$!
else
  echo "PASS" > "$LOG_DIR/gemini.log"
  PID_GEMINI=""
  START_GEMINI=0
fi

# 4. Codex Review (Network - Strict Logic)
# Uses codex CLI to review changes for bugs and quality
if [ ${#CHANGED_ENGINES[@]} -gt 0 ]; then
  START_CODEX=$(date +%s)
  ({ cat prompts/code-review.md; echo -e "\n---\nENGINE CONTEXT (for reference only):\nThe following engines have changes. Use them for context, but only review code that appears in the DIFF section below.\n$ENGINE_CONTEXT\n\n---\nDIFF:\n\n$GIT_DIFF"; } | codex exec "Review the code DIFF below for bugs and quality issues based on the instructions above. Only review lines that appear in the DIFF section. The engine context is provided for reference only - do not generate feedback for unchanged code. Respond with PASS or a list of issues." > "$LOG_DIR/codex.log" 2>&1) & PID_CODEX=$!
else
  echo "PASS" > "$LOG_DIR/codex.log"
  PID_CODEX=""
  START_CODEX=0
fi

# Wait for all processes and record end times
wait $PID_LINT; EXIT_LINT=$?
END_LINT=$(date +%s)
DURATION_LINT=$((END_LINT - START_LINT))

wait $PID_TEST; EXIT_TEST=$?
END_TEST=$(date +%s)
DURATION_TEST=$((END_TEST - START_TEST))

wait $PID_PACKWERK; EXIT_PACKWERK=$?
END_PACKWERK=$(date +%s)
DURATION_PACKWERK=$((END_PACKWERK - START_PACKWERK))

if [ -n "$PID_GEMINI" ]; then
  wait $PID_GEMINI; EXIT_GEMINI=$?
  END_GEMINI=$(date +%s)
  DURATION_GEMINI=$((END_GEMINI - START_GEMINI))
else
  EXIT_GEMINI=0
  DURATION_GEMINI=0
fi

if [ -n "$PID_CODEX" ]; then
  wait $PID_CODEX; EXIT_CODEX=$?
  END_CODEX=$(date +%s)
  DURATION_CODEX=$((END_CODEX - START_CODEX))
else
  EXIT_CODEX=0
  DURATION_CODEX=0
fi

# Results Synthesis
echo "--- Gauntlet Results ---"

if [ $EXIT_LINT -eq 0 ]; then
  echo "✅ StandardRB: Pass (${DURATION_LINT}s)"
else
  echo "❌ StandardRB: Fail (${DURATION_LINT}s) (See $LOG_DIR/standardrb.log)"
fi

if [ $EXIT_TEST -eq 0 ]; then
  echo "✅ RSpec: Pass (${DURATION_TEST}s)"
else
  echo "❌ RSpec: Fail (${DURATION_TEST}s) (See $LOG_DIR/rspec.log)"
fi

if [ $EXIT_PACKWERK -eq 0 ]; then
  echo "✅ Packwerk: Pass (${DURATION_PACKWERK}s)"
else
  echo "❌ Packwerk: Fail (${DURATION_PACKWERK}s) (See $LOG_DIR/packwerk.log)"
fi

if grep -q "PASS" "$LOG_DIR/gemini.log"; then
  if [ $DURATION_GEMINI -gt 0 ]; then
    echo "✅ Gemini: Pass (${DURATION_GEMINI}s)"
  else
    echo "✅ Gemini: Pass (skipped)"
  fi
else
  if [ $DURATION_GEMINI -gt 0 ]; then
    echo "❌ Gemini: Fail (${DURATION_GEMINI}s) (See $LOG_DIR/gemini.log)"
  else
    echo "❌ Gemini: Fail (skipped) (See $LOG_DIR/gemini.log)"
  fi
fi

if grep -q "PASS" "$LOG_DIR/codex.log"; then
  if [ $DURATION_CODEX -gt 0 ]; then
    echo "✅ Codex: Pass (${DURATION_CODEX}s)"
  else
    echo "✅ Codex: Pass (skipped)"
  fi
else
  if [ $DURATION_CODEX -gt 0 ]; then
    echo "❌ Codex: Fail (${DURATION_CODEX}s) (See $LOG_DIR/codex.log)"
  else
    echo "❌ Codex: Fail (skipped) (See $LOG_DIR/codex.log)"
  fi
fi

# Exit with error if any part failed
if [ $EXIT_LINT -eq 0 ] && [ $EXIT_TEST -eq 0 ] && [ $EXIT_PACKWERK -eq 0 ] && grep -q "PASS" "$LOG_DIR/gemini.log" && grep -q "PASS" "$LOG_DIR/codex.log"; then
  echo "🎉 SUCCESS: All verification gates passed."
  exit 0
else
  echo "💥 FAILURE: One or more checks failed."
  exit 1
fi
