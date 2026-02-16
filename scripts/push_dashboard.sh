#!/bin/bash
# Dashboard auto-push script
# Used by Karo after updating dashboard.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/shogun-dashboard"
SOURCE_FILE="$SCRIPT_DIR/dashboard.md"
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
  bash "$SCRIPT_DIR/scripts/ntfy.sh" "📊 軍議場更新"
fi
