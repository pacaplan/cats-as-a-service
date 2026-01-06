#!/bin/bash
#
# Updates rampart-core gem across the entire monorepo
#
# Usage:
#   ./scripts/update_rampart.sh          # Updates to latest version matching constraint
#   ./scripts/update_rampart.sh 0.1.3    # Updates constraint to ~> 0.1.3 and bundles
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$ROOT_DIR/config/rampart_version.rb"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
  echo -e "${BLUE}==>${NC} $1"
}

success() {
  echo -e "${GREEN}✓${NC} $1"
}

# Update version constraint if version provided
if [ -n "$1" ]; then
  NEW_VERSION="$1"
  log "Updating RAMPART_VERSION to ~> $NEW_VERSION"
  cat > "$VERSION_FILE" << EOF
# Shared Rampart version constraint
# Update this single file when upgrading rampart-core across the monorepo
RAMPART_VERSION = "~> $NEW_VERSION"
EOF
  success "Updated $VERSION_FILE"
fi

# Show current version constraint
log "Current version constraint:"
grep RAMPART_VERSION "$VERSION_FILE"

# Clear Bundler cache to force fresh gem index lookup
log "Clearing Bundler cache for fresh gem index..."
rm -rf "$ROOT_DIR/vendor/bundle" "$ROOT_DIR/.bundle" 2>/dev/null || true

# Bundle root
log "Bundling root..."
cd "$ROOT_DIR"
bundle install
success "Root bundled"

# Bundle apps/api
log "Bundling apps/api..."
cd "$ROOT_DIR/apps/api"
bundle update rampart-core
success "apps/api bundled"

# Bundle all engines
for engine_dir in "$ROOT_DIR/engines"/*; do
  if [ -d "$engine_dir" ] && [ -f "$engine_dir/Gemfile" ]; then
    engine_name=$(basename "$engine_dir")
    log "Bundling engines/$engine_name..."
    cd "$engine_dir"
    bundle update rampart-core
    success "engines/$engine_name bundled"
  fi
done

# Show installed version
echo ""
log "Installed rampart-core version:"
cd "$ROOT_DIR"
bundle info rampart-core | grep -E "rampart-core|Path"

echo ""
success "All projects updated to rampart-core!"

