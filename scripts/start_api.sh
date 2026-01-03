#!/usr/bin/env bash
set -e

echo "Starting API server on http://localhost:8000"
cd apps/api
bundle exec rails server -p 8000
