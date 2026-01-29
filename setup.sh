#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
TARGET_DIR="$HOME/.claude/skills"

echo "=== Ticket-to-PR Pipeline Setup ==="
echo

# Check required CLIs
echo "Checking required CLIs..."
missing=()

if ! command -v gh &>/dev/null; then
    missing+=("gh (GitHub CLI)")
fi

if ! command -v coderabbit &>/dev/null; then
    missing+=("coderabbit")
fi

if [ ${#missing[@]} -gt 0 ]; then
    echo "⚠️  Missing required CLIs:"
    for cli in "${missing[@]}"; do
        echo "   - $cli"
    done
    echo
else
    echo "✓ All required CLIs found"
fi

# Create runs directory
echo
echo "Creating runs/ directory..."
mkdir -p "$SCRIPT_DIR/runs"
echo "✓ runs/ directory ready"

# Create symlinks for skills
echo
echo "Creating skill symlinks in $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

for skill_path in "$SKILLS_DIR"/*/; do
    if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        target_link="$TARGET_DIR/$skill_name"
        
        if [ -L "$target_link" ]; then
            rm "$target_link"
        fi
        
        if [ -e "$target_link" ]; then
            echo "   ⚠️  Skipping $skill_name (non-symlink exists at target)"
        else
            ln -s "$skill_path" "$target_link"
            echo "   ✓ $skill_name"
        fi
    fi
done

echo
echo "=== Setup Complete ==="
echo
echo "Skills are now available via: amp /skill <skill-name>"
echo "Run status checks with: make status"
