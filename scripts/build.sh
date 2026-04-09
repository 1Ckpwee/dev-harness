#!/usr/bin/env bash
# build.sh — Launch Claude Code as the Builder agent
# Usage: duo build [project_dir]

set -euo pipefail

TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DUO_DIR="${TARGET_DIR}/.duo"

if [[ ! -d "$DUO_DIR" ]]; then
    echo "Error: No .duo/ found at ${TARGET_DIR}"
    echo "Run: duo init ${TARGET_DIR}"
    exit 1
fi

# Build the prompt from duo files
PROMPT="You are the Builder agent in a dual-agent workflow.

START by reading these files in order:
1. .duo/roles/builder-brief.md
2. .duo/coordination/task-board.md
3. .duo/coordination/progress-log.md
4. .duo/taste/principles.md
5. .duo/quality/output-format.md

Then pick the next unblocked task assigned to 'builder' from the task board and execute it.
When done, generate a handoff file in .duo/handoffs/ following the format in output-format.md.
Update task-board.md and progress-log.md before finishing."

echo "=== Launching Builder (Claude Code) ==="
echo "Project: ${TARGET_DIR}"
echo "=================================="
echo ""

# Launch Claude Code with the builder prompt
# --print for non-interactive, or without for interactive session
if [[ "${NONINTERACTIVE:-}" == "1" ]]; then
    cd "$TARGET_DIR" && claude --print "$PROMPT"
else
    cd "$TARGET_DIR" && claude "$PROMPT"
fi
