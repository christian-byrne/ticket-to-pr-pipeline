#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNS_DIR="$SCRIPT_DIR/../runs"

if [ ! -d "$RUNS_DIR" ]; then
    echo "No runs directory found."
    exit 0
fi

echo "=== Pipeline Runs ==="
echo

found=0
for run_dir in "$RUNS_DIR"/*/; do
    if [ -d "$run_dir" ]; then
        run_id=$(basename "$run_dir")
        status_file="$run_dir/status.json"
        
        if [ -f "$status_file" ]; then
            found=1
            status=$(jq -r '.status // "unknown"' "$status_file" 2>/dev/null || echo "error")
            ticket_url=$(jq -r '.ticketUrl // "-"' "$status_file" 2>/dev/null || echo "-")
            pr_url=$(jq -r '.prUrl // "-"' "$status_file" 2>/dev/null || echo "-")
            last_updated=$(jq -r '.lastUpdated // "-"' "$status_file" 2>/dev/null || echo "-")
            
            echo "Run: $run_id"
            echo "  Status:       $status"
            echo "  Ticket:       $ticket_url"
            [ "$pr_url" != "-" ] && [ "$pr_url" != "null" ] && echo "  PR:           $pr_url"
            echo "  Last Updated: $last_updated"
            echo
        fi
    fi
done

if [ $found -eq 0 ]; then
    echo "No pipeline runs found."
fi
