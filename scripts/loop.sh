#!/usr/bin/env bash
# loop.sh — Run one full build-review cycle
# Usage: duo loop [project_dir] [--yes]
#
# This runs one iteration of:
#   1. Builder (Claude Code) executes next task → generates handoff
#   2. Reviewer (Codex) reviews the handoff → generates review
#   3. Displays summary for human decision
#
# Use --yes to skip all confirmations (CI mode)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"
shift || true

# Handle --yes flag
AUTO_MODE=""
if [[ "${1:-}" == "--yes" ]]; then
    AUTO_MODE="1"
    shift
fi
if [[ "${1:-}" != "" ]]; then
    TARGET_DIR="${1}"
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DUO_DIR="${TARGET_DIR}/.duo"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── confirm() ─────────────────────────────────────────────
# Usage: confirm "Agent Name" "description"
# Exits 0 on proceed, exits 1 on abort
confirm() {
    local agent="$1"
    local description="$2"

    if [[ -n "$AUTO_MODE" ]]; then
        echo -e "${BLUE}[AUTO]${NC} ${agent}: ${description}"
        return 0
    fi

    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  Confirm before automated execution       ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}${agent}${NC} is about to:"
    echo "  ${description}"
    echo ""
    read -p "Proceed? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Aborted."
        exit 1
    fi
}

if [[ ! -d "$DUO_DIR" ]]; then
    echo -e "${RED}Error: No .duo/ found at ${TARGET_DIR}${NC}"
    echo "Run: duo init ${TARGET_DIR}"
    exit 1
fi

echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Duo Dev — Loop Cycle        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo ""

# Phase 1: Build (non-interactive, skip permissions)
confirm "Builder (Claude Code)" "Execute next task from plan.md"
echo -e "${GREEN}▶ Phase 1: Builder (Claude Code)${NC}"
echo "───────────────────────────────────"
cd "$TARGET_DIR" && claude -p --dangerously-skip-permissions \
    "You are the Builder agent. START by reading: .duo/roles/builder-brief.md, .duo/plans/plan.md, .duo/coordination/progress-log.md, .duo/taste/principles.md, .duo/quality/output-format.md. Pick the next incomplete task from plan.md and execute it. Generate a handoff file in .duo/handoffs/. Update progress-log.md before finishing."

echo ""
echo -e "${BLUE}✓ Builder phase complete${NC}"

# Phase 2: Review (non-interactive, full auto)
confirm "Reviewer (Codex)" "Review Builder's handoff against plan.md"
echo ""
echo -e "${GREEN}▶ Phase 2: Reviewer (Codex)${NC}"
echo "───────────────────────────────────"
cd "$TARGET_DIR" && codex -q --full-auto \
    "You are the Reviewer agent. START by reading: .duo/roles/reviewer-brief.md, .duo/plans/plan.md (acceptance criteria), .duo/quality/review-checklist.md, .duo/taste/principles.md. Read the latest handoff in .duo/handoffs/. Verify code against source. Grade against the acceptance criteria in plan.md. Generate a structured review in .duo/reviews/. Output verdict as: PASS | PASS_WITH_NOTES | FAIL with issues. Update progress-log.md."

echo ""
echo -e "${BLUE}✓ Reviewer phase complete${NC}"

echo ""
echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Cycle Complete             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo ""

# Show latest review verdict
LATEST_REVIEW=$(ls -t "${DUO_DIR}/reviews/"review_*.md 2>/dev/null | head -1)
if [[ -n "$LATEST_REVIEW" ]]; then
    VERDICT=$(grep -i "^verdict" "$LATEST_REVIEW" 2>/dev/null | head -1 || echo "Verdict: Unknown")
    echo -e "Latest review: ${YELLOW}${VERDICT}${NC}"
    echo "Full review: ${LATEST_REVIEW}"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  • If PASS     → Move to next task"
echo "  • If FAIL     → Run 'duo loop' to retry"
echo "  • If disputed → Edit task-board.md manually, then re-run"
