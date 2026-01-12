#!/usr/bin/env bash
set -e

# Change to project root (parent of scripts directory)
cd "$(dirname "$0")/.."

echo "Starting API server on http://localhost:8000"
cd apps/api
bundle exec rails server -p 8000
