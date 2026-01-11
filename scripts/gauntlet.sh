#!/bin/bash
# scripts/gauntlet.sh - Parallel Verification Suite

# Ensure we are in the project root
cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"

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
echo "▶️  Starting StandardRB..."
START_LINT=$(date +%s)
(run_lints) & PID_LINT=$!

echo "▶️  Starting RSpec..."
START_TEST=$(date +%s)
(run_specs) & PID_TEST=$!

# 2. Packwerk (Architecture)
echo "▶️  Starting Packwerk..."
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
if [ ${#CHANGED_ENGINES[@]} -gt 0 ] && command -v gemini >/dev/null 2>&1; then
  echo "▶️  Starting Gemini review..."
  START_GEMINI=$(date +%s)
  # Build the full prompt with diff
  GEMINI_INPUT=$(cat <<EOF
Review the code DIFF below for Hexagonal Architecture adherence based on the instructions in the prompt file. Only review lines that appear in the DIFF section. The engine context is provided for reference only - do not generate feedback for unchanged code.

---
DIFF:

$GIT_DIFF
EOF
)
  (
    {
      echo "Gemini Review Log"
      echo "-----------------"
      echo "Timestamp: $(date)"
      echo "Model: default"
      echo "Context: @prompts/rampart-review.md$ENGINE_CONTEXT"
      echo "-----------------"
      echo ""
      echo "$GEMINI_INPUT" | gemini -p "@prompts/rampart-review.md$ENGINE_CONTEXT"
    } > "$LOG_DIR/gemini.log" 2>&1
  ) & PID_GEMINI=$!
else
  if [ ${#CHANGED_ENGINES[@]} -gt 0 ]; then
    echo "⚠️ Gemini CLI not found, skipping review" > "$LOG_DIR/gemini.log"
  else
    echo "PASS" > "$LOG_DIR/gemini.log"
  fi
  PID_GEMINI=""
  START_GEMINI=0
fi

# 4. Codex Review (Network - Strict Logic)
# Uses codex CLI to review changes for bugs and quality
if [ ${#CHANGED_ENGINES[@]} -gt 0 ] && command -v codex >/dev/null 2>&1; then
  echo "▶️  Starting Codex review..."
  START_CODEX=$(date +%s)
  # Build the prompt with instructions
  CODEX_PROMPT="$(cat prompts/code-review.md)

ENGINE CONTEXT (for reference only): The following engines have changes: $ENGINE_CONTEXT. Use them for context, but only review code that appears in the DIFF.

Review the code DIFF provided below for bugs and quality issues. Only review lines that appear in the DIFF. The engine context is for reference only - do not generate feedback for unchanged code. Respond with PASS or a list of issues."
  
  # Pass the diff as stdin to codex exec using gpt-5.2-codex model
  (echo "$GIT_DIFF" | codex exec -m gpt-5.2-codex "$CODEX_PROMPT" > "$LOG_DIR/codex.log" 2>&1) & PID_CODEX=$!
else
  if [ ${#CHANGED_ENGINES[@]} -gt 0 ]; then
    echo "⚠️ Codex CLI not found, skipping review" > "$LOG_DIR/codex.log"
  else
    echo "PASS" > "$LOG_DIR/codex.log"
  fi
  PID_CODEX=""
  START_CODEX=0
fi

# Wait for all processes and record end times, printing completion messages in real-time
wait $PID_LINT; EXIT_LINT=$?
END_LINT=$(date +%s)
DURATION_LINT=$((END_LINT - START_LINT))
if [ $EXIT_LINT -eq 0 ]; then
  echo "✅ StandardRB: Complete (${DURATION_LINT}s)"
else
  echo "❌ StandardRB: Failed (${DURATION_LINT}s) (See $LOG_DIR/standardrb.log)"
fi

wait $PID_TEST; EXIT_TEST=$?
END_TEST=$(date +%s)
DURATION_TEST=$((END_TEST - START_TEST))
if [ $EXIT_TEST -eq 0 ]; then
  echo "✅ RSpec: Complete (${DURATION_TEST}s)"
else
  echo "❌ RSpec: Failed (${DURATION_TEST}s) (See $LOG_DIR/rspec.log)"
fi

wait $PID_PACKWERK; EXIT_PACKWERK=$?
END_PACKWERK=$(date +%s)
DURATION_PACKWERK=$((END_PACKWERK - START_PACKWERK))
if [ $EXIT_PACKWERK -eq 0 ]; then
  echo "✅ Packwerk: Complete (${DURATION_PACKWERK}s)"
else
  echo "❌ Packwerk: Failed (${DURATION_PACKWERK}s) (See $LOG_DIR/packwerk.log)"
fi

if [ -n "$PID_GEMINI" ]; then
  wait $PID_GEMINI; EXIT_GEMINI=$?
  END_GEMINI=$(date +%s)
  DURATION_GEMINI=$((END_GEMINI - START_GEMINI))
  # Check Gemini result and print immediately
  if grep -q "not found" "$LOG_DIR/gemini.log"; then
    echo "⚠️  Gemini: Skipped (CLI not installed)"
  elif grep -qi "PASS" "$LOG_DIR/gemini.log"; then
    echo "✅ Gemini: Complete (${DURATION_GEMINI}s)"
  elif grep -q "❌ Violations" "$LOG_DIR/gemini.log" && grep -qi "None Found\|No violations" "$LOG_DIR/gemini.log"; then
    echo "✅ Gemini: Complete (${DURATION_GEMINI}s)"
  elif grep -q "❌ Violations" "$LOG_DIR/gemini.log"; then
    echo "❌ Gemini: Failed (${DURATION_GEMINI}s) (See $LOG_DIR/gemini.log)"
  else
    echo "✅ Gemini: Complete (${DURATION_GEMINI}s)"
  fi
else
  EXIT_GEMINI=0
  DURATION_GEMINI=0
fi

if [ -n "$PID_CODEX" ]; then
  wait $PID_CODEX; EXIT_CODEX=$?
  END_CODEX=$(date +%s)
  DURATION_CODEX=$((END_CODEX - START_CODEX))
  # Check Codex result and print immediately
  if grep -q "PASS" "$LOG_DIR/codex.log"; then
    echo "✅ Codex: Complete (${DURATION_CODEX}s)"
  elif grep -q "not found" "$LOG_DIR/codex.log"; then
    echo "⚠️  Codex: Skipped (CLI not installed)"
  else
    echo "❌ Codex: Failed (${DURATION_CODEX}s) (See $LOG_DIR/codex.log)"
  fi
else
  EXIT_CODEX=0
  DURATION_CODEX=0
fi

# Results Summary
echo ""
echo "--- Gauntlet Summary ---"

# Exit with error if any part failed (skip AI reviews if CLI not installed)
# Gemini passes if it says "None Found" or "No violations" or explicitly "PASS"
GEMINI_PASS=0
if grep -q "not found" "$LOG_DIR/gemini.log"; then
  GEMINI_PASS=0  # Skipped is OK
elif grep -qi "PASS" "$LOG_DIR/gemini.log"; then
  GEMINI_PASS=0  # Explicit PASS
elif grep -q "❌ Violations" "$LOG_DIR/gemini.log" && grep -qi "None Found\|No violations" "$LOG_DIR/gemini.log"; then
  GEMINI_PASS=0  # Violations section says "None Found" - pass
elif grep -q "❌ Violations" "$LOG_DIR/gemini.log"; then
  GEMINI_PASS=1  # Has actual violations
else
  GEMINI_PASS=0  # Default to pass if unclear
fi

CODEX_PASS=$(grep -q "PASS\|not found" "$LOG_DIR/codex.log" && echo 0 || echo 1)

if [ $EXIT_LINT -eq 0 ] && [ $EXIT_TEST -eq 0 ] && [ $EXIT_PACKWERK -eq 0 ] && [ $GEMINI_PASS -eq 0 ] && [ $CODEX_PASS -eq 0 ]; then
  echo "🎉 SUCCESS: All verification gates passed."
  exit 0
else
  echo "💥 FAILURE: One or more checks failed."
  exit 1
fi
