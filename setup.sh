#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
TARGET_DIR="$HOME/.claude/skills"
ENV_FILE="$HOME/.config/ticket-to-pr-pipeline/env"

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

# Create environment config
echo
echo "Creating environment configuration..."
mkdir -p "$(dirname "$ENV_FILE")"

if [ ! -f "$ENV_FILE" ]; then
    cat > "$ENV_FILE" << EOF
# Ticket-to-PR Pipeline Environment
# Source this file or add to your shell profile

export PIPELINE_ROOT="$SCRIPT_DIR"
export COMFY_FRONTEND=""  # Set to your ComfyUI_frontend clone path
EOF
    echo "✓ Created $ENV_FILE"
    echo "   ⚠️  Edit this file to set COMFY_FRONTEND path"
else
    echo "✓ Environment file already exists at $ENV_FILE"
fi

echo
echo "=== Setup Complete ==="
echo
echo "1. Edit $ENV_FILE to set COMFY_FRONTEND"
echo "2. Add to your shell profile: source $ENV_FILE"
echo "3. Skills are now available via: amp /skill <skill-name>"
echo "4. Run status checks with: make status"
