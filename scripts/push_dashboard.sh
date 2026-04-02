#!/bin/bash
# Dashboard auto-push script
# Pushes dashboard.md to configured external repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="$SCRIPT_DIR/config/settings.yaml"
SOURCE_FILE="$SCRIPT_DIR/dashboard.md"

# Read configuration from settings.yaml
REPO_URL=$(grep -A3 'dashboard_push:' "$SETTINGS" | grep 'repo:' | awk '{print $2}' | tr -d '"')
BRANCH=$(grep -A3 'dashboard_push:' "$SETTINGS" | grep 'branch:' | awk '{print $2}' | tr -d '"')
SUBDIR=$(grep -A3 'dashboard_push:' "$SETTINGS" | grep 'subdirectory:' | awk '{print $2}' | tr -d '"')

# Skip if not configured
if [ -z "$REPO_URL" ]; then
  echo "Dashboard push not configured. Run: bash scripts/setup_dashboard_push.sh"
  exit 0
fi

# Set defaults
BRANCH=${BRANCH:-main}
REPO_DIR="$SCRIPT_DIR/.dashboard-repo"

# Clone if not exists
if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning dashboard repository..."
  git clone "$REPO_URL" "$REPO_DIR" || {
    echo "Error: Failed to clone repository"
    exit 1
  }
fi

# Determine target file path
if [ -n "$SUBDIR" ]; then
  TARGET_DIR="$REPO_DIR/$SUBDIR"
  TARGET_FILE="$TARGET_DIR/dashboard.md"
  mkdir -p "$TARGET_DIR"
else
  TARGET_FILE="$REPO_DIR/dashboard.md"
fi

# Copy dashboard
cp "$SOURCE_FILE" "$TARGET_FILE"

# Git operations
cd "$REPO_DIR"
git add .

if git diff --cached --quiet; then
  echo "No changes to push."
else
  git commit -m "update: dashboard $(date '+%Y-%m-%d %H:%M')"
  git push origin "$BRANCH"
  echo "Dashboard pushed successfully."

  # Send ntfy notification if configured
  NTFY_TOPIC=$(grep 'ntfy_topic:' "$SETTINGS" 2>/dev/null | awk '{print $2}' | tr -d '"')
  if [ -n "$NTFY_TOPIC" ]; then
    bash "$SCRIPT_DIR/scripts/ntfy.sh" "📊 軍議場更新"
  fi
fi
