#!/usr/bin/env bash
# build.sh — Launch Claude Code as the Builder agent
# Usage: harness build [project_dir]

set -euo pipefail

TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
HARNESS_DIR="${TARGET_DIR}/.harness"

if [[ ! -d "$HARNESS_DIR" ]]; then
    echo "Error: No .harness/ found at ${TARGET_DIR}"
    echo "Run: harness init ${TARGET_DIR}"
    exit 1
fi

# Build the prompt from harness files
PROMPT="You are the Builder agent in a dual-agent workflow.

START by reading these files in order:
1. .harness/roles/builder-brief.md
2. .harness/coordination/task-board.md
3. .harness/coordination/progress-log.md
4. .harness/taste/principles.md
5. .harness/quality/output-format.md

Then pick the next unblocked task assigned to 'builder' from the task board and execute it.
When done, generate a handoff file in .harness/handoffs/ following the format in output-format.md.
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
