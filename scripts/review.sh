#!/usr/bin/env bash
# review.sh — Launch Codex as the Reviewer agent
# Usage: duo review [project_dir]

set -euo pipefail

TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DUO_DIR="${TARGET_DIR}/.duo"

if [[ ! -d "$DUO_DIR" ]]; then
    echo "Error: No .duo/ found at ${TARGET_DIR}"
    echo "Run: duo init ${TARGET_DIR}"
    exit 1
fi

# Find latest handoff file
LATEST_HANDOFF=$(ls -t "${DUO_DIR}/handoffs/"handoff_*.md 2>/dev/null | head -1)

if [[ -z "$LATEST_HANDOFF" ]]; then
    echo "Warning: No handoff files found in ${DUO_DIR}/handoffs/"
    echo "The Builder agent needs to complete work and generate a handoff first."
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    HANDOFF_INSTRUCTION="No handoff file exists yet. Review the current state of the codebase and task board."
else
    HANDOFF_NAME=$(basename "$LATEST_HANDOFF")
    HANDOFF_INSTRUCTION="Read the latest handoff file: .duo/handoffs/${HANDOFF_NAME}"
fi

PROMPT="You are the Reviewer agent in a dual-agent workflow.

START by reading these files in order:
1. .duo/roles/reviewer-brief.md
2. ${HANDOFF_INSTRUCTION}
3. .duo/quality/review-checklist.md
4. .duo/taste/principles.md

Then review the Builder's work:
- Verify all code references against actual source files
- Grade against the review checklist
- Generate a review file in .duo/reviews/ following .duo/quality/output-format.md
- Update task-board.md and progress-log.md with your findings"

echo "=== Launching Reviewer (Codex) ==="
echo "Project: ${TARGET_DIR}"
if [[ -n "$LATEST_HANDOFF" ]]; then
    echo "Reviewing: $(basename "$LATEST_HANDOFF")"
fi
echo "=================================="
echo ""

# Launch Codex with the reviewer prompt
cd "$TARGET_DIR" && codex "$PROMPT"
