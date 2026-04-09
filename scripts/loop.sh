#!/usr/bin/env bash
# loop.sh — Run one full build-review cycle
# Usage: harness loop [project_dir]
#
# This runs one iteration of:
#   1. Builder (Claude Code) executes next task → generates handoff
#   2. Reviewer (Codex) reviews the handoff → generates review
#   3. Displays summary for human decision

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
HARNESS_DIR="${TARGET_DIR}/.harness"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ ! -d "$HARNESS_DIR" ]]; then
    echo -e "${RED}Error: No .harness/ found at ${TARGET_DIR}${NC}"
    echo "Run: harness init ${TARGET_DIR}"
    exit 1
fi

echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Dev Harness — Loop Cycle      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo ""

# Phase 1: Build
echo -e "${GREEN}▶ Phase 1: Builder (Claude Code)${NC}"
echo "───────────────────────────────────"
"${SCRIPT_DIR}/build.sh" "$TARGET_DIR"

echo ""
echo -e "${YELLOW}Builder phase complete.${NC}"
read -p "Continue to Review phase? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Paused. Run 'harness review' when ready."
    exit 0
fi

# Phase 2: Review
echo ""
echo -e "${GREEN}▶ Phase 2: Reviewer (Codex)${NC}"
echo "───────────────────────────────────"
"${SCRIPT_DIR}/review.sh" "$TARGET_DIR"

echo ""
echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Cycle Complete             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo ""

# Show latest review verdict
LATEST_REVIEW=$(ls -t "${HARNESS_DIR}/reviews/"review_*.md 2>/dev/null | head -1)
if [[ -n "$LATEST_REVIEW" ]]; then
    VERDICT=$(grep -i "verdict" "$LATEST_REVIEW" | head -1 || echo "Unknown")
    echo -e "Latest review: ${YELLOW}${VERDICT}${NC}"
    echo "Full review: ${LATEST_REVIEW}"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  • If PASS     → Move to next task"
echo "  • If FAIL     → Run 'harness build' to fix issues"
echo "  • If disputed → Edit task-board.md manually, then re-run"
