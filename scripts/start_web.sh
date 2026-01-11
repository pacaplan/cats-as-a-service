#!/usr/bin/env bash
set -e

# Change to project root (parent of scripts directory)
cd "$(dirname "$0")/.."

echo "Starting web server on http://localhost:3000"
cd apps/web
npm run dev
