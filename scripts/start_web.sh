#!/usr/bin/env bash
set -e

echo "Starting web server on http://localhost:3000"
cd apps/web
npm run dev
