#!/bin/bash
# Run Packwerk checks from the correct Rails app context
#
# Usage:
#   ./scripts/check-packwerk.sh              # Check all engines
#   ./scripts/check-packwerk.sh cat_content  # Check specific engine

set -e

# Navigate to the api app where Packwerk is configured
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT/apps/api"

ENGINE=$1

if [ -z "$ENGINE" ]; then
  echo "🔍 Checking all engines..."
  bundle exec packwerk check
else
  echo "🔍 Checking engine: $ENGINE..."
  bundle exec packwerk check "../../engines/$ENGINE"
fi
