#!/bin/bash
# Dashboard auto-push script
# Used by Karo after updating dashboard.md

set -e

REPO_DIR="/Users/s20815/shogun-dashboard"
SOURCE_FILE="/Users/s20815/multi-agent-shogun/dashboard.md"
TARGET_FILE="$REPO_DIR/mac/dashboard.md"

# Check file existence
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: Source file not found: $SOURCE_FILE"
  exit 1
fi

if [ ! -d "$REPO_DIR" ]; then
  echo "Error: Repository directory not found: $REPO_DIR"
  exit 1
fi

# Copy dashboard file
cp "$SOURCE_FILE" "$TARGET_FILE"

# Git operations
cd "$REPO_DIR"
git add mac/dashboard.md

# Commit and push if changes exist
if git diff --cached --quiet; then
  echo "No changes to push."
else
  git commit -m "update: dashboard $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "Dashboard pushed successfully."
fi
