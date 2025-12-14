#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Rampart development servers...${NC}"
echo ""
echo -e "${GREEN}Web app:${NC} http://localhost:3000"
echo -e "${GREEN}API:${NC}     http://localhost:8000"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all servers${NC}"
echo ""

# Function to cleanup background processes on exit
cleanup() {
  echo ""
  echo "Stopping servers..."
  if [ ! -z "$API_PID" ]; then
    kill $API_PID 2>/dev/null || true
  fi
  if [ ! -z "$WEB_PID" ]; then
    kill $WEB_PID 2>/dev/null || true
  fi
  # Kill any child processes
  pkill -P $$ 2>/dev/null || true
  exit
}

trap cleanup SIGINT SIGTERM EXIT

# Start API server
echo -e "${BLUE}[API]${NC} Starting Rails server on port 8000..."
(
  cd apps/api
  bundle exec rails server -p 8000
) &
API_PID=$!

# Give API a moment to start
sleep 3

# Start Web server
echo -e "${BLUE}[Web]${NC} Starting Next.js dev server on port 3000..."
(
  cd apps/web
  npm run dev
) &
WEB_PID=$!

# Wait for both processes
wait


