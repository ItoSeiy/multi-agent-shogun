#!/bin/bash
# Dashboard push setup script
# Configures external repository for auto-pushing dashboard.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="$SCRIPT_DIR/config/settings.yaml"

echo "=== Dashboard Push Setup ==="
echo ""
echo "This script configures automatic push of dashboard.md to an external repository."
echo ""

# Step 1: Create GitHub repository
echo "Step 1: Create a GitHub repository (private recommended)"
echo "Example: gh repo create shogun-dashboard --private"
echo ""
read -p "Have you created the repository? (y/n): " created
if [ "$created" != "y" ]; then
  echo "Please create the repository first."
  exit 1
fi

# Step 2: Repository URL
echo ""
echo "Step 2: Enter repository URL"
read -p "Repository URL (e.g., git@github.com:user/shogun-dashboard.git): " repo_url

# Step 3: Branch
echo ""
read -p "Branch name (default: main): " branch
branch=${branch:-main}

# Step 4: Subdirectory
echo ""
read -p "Subdirectory (leave empty for root, e.g., 'mac'): " subdir

# Step 5: Write to settings.yaml
echo ""
echo "Writing configuration to settings.yaml..."

# Use awk to update YAML (more portable than Python)
awk -v repo="$repo_url" -v branch="$branch" -v subdir="$subdir" '
/^dashboard_push:/ { in_section=1 }
in_section && /^  repo:/ { print "  repo: \"" repo "\""; next }
in_section && /^  branch:/ { print "  branch: \"" branch "\""; next }
in_section && /^  subdirectory:/ { print "  subdirectory: \"" subdir "\""; in_section=0; next }
{ print }
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

echo "✓ Configuration saved."

# Step 6: Clone repository
echo ""
echo "Cloning repository..."
REPO_DIR="$SCRIPT_DIR/.dashboard-repo"
if [ -d "$REPO_DIR" ]; then
  rm -rf "$REPO_DIR"
fi
git clone "$repo_url" "$REPO_DIR"

# Step 7: Initial push
echo ""
read -p "Push current dashboard.md to repository? (y/n): " do_push
if [ "$do_push" = "y" ]; then
  bash "$SCRIPT_DIR/scripts/push_dashboard.sh"
  echo "✓ Dashboard pushed."
fi

echo ""
echo "=== Setup Complete ==="
echo "Dashboard push is now configured."
echo "The dashboard will be automatically pushed when Karo updates it."
