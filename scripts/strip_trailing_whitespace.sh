#!/bin/bash
# Strip trailing blank lines from files that have them added in git diff
# This script finds files with only trailing whitespace changes and reverts them

set -e

cd "$(dirname "$0")/.."

echo "Finding files with trailing whitespace added..."

# Get list of modified files from git diff
files=$(git diff --name-only)

for file in $files; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  # Check if the only change is adding trailing newlines
  # Get the diff for this specific file
  diff_output=$(git diff -- "$file")
  
  # Check if diff only contains additions of empty lines at the end
  # A trailing newline addition looks like: +\n at the end of the diff
  additions=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
  deletions=$(echo "$diff_output" | grep '^-' | grep -v '^---' || true)
  
  # If the only additions are empty lines and there are no deletions,
  # this is just trailing whitespace
  if [ -z "$deletions" ]; then
    # Check if all additions are just empty lines
    non_empty_additions=$(echo "$additions" | grep -v '^+$' | grep -v '^+[[:space:]]*$' || true)
    
    if [ -z "$non_empty_additions" ] && [ -n "$additions" ]; then
      echo "Reverting trailing whitespace in: $file"
      git checkout -- "$file"
    fi
  else
    # There are real changes - just strip trailing blank lines from the file
    # without reverting other changes
    echo "Stripping trailing blank lines from: $file"
    
    # Remove trailing blank lines while preserving the final newline
    # This uses a temp file approach for safety
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS version
      sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$file"
    else
      # Linux version
      sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$file"
    fi
  fi
done

echo ""
echo "Done! Run 'git diff' to verify changes."

