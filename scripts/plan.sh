#!/usr/bin/env bash
# plan.sh — Planner agent: generate a plan from user intent
# Usage: duo plan "实现用户登录功能" [project_dir] [--yes]

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

# Remaining positional is the intent string
INTENT="${1:-}"
if [[ -z "$INTENT" ]]; then
    echo "Error: missing intent description"
    echo "Usage: duo plan \"实现用户登录功能\" [project_dir] [--yes]"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DUO_DIR="${TARGET_DIR}/.duo"

if [[ ! -d "$DUO_DIR" ]]; then
    echo "Error: No .duo/ found at ${TARGET_DIR}"
    echo "Run: duo init ${TARGET_DIR}"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── confirm() ─────────────────────────────────────────────
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

echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Duo Dev — Planner          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo ""

confirm "Planner (Claude Code)" "Generate a plan for: ${INTENT}"

echo -e "${GREEN}▶ Planner (Claude Code)${NC}"
echo "───────────────────────────────────"
echo "Intent: ${INTENT}"
echo ""

# Generate plan using Claude Code
cd "$TARGET_DIR" && claude -p --dangerously-skip-permissions \
    "You are the Planner agent. Read .duo/taste/principles.md and .duo/coordination/context-map.md (if it exists).
Then create a plan for the following user intent:

${INTENT}

Generate the plan as a markdown file at .duo/plans/plan.md
(if .duo/plans/ does not exist, create it).

The plan MUST include:
1. Intent (the original request)
2. Scope (in scope / out of scope)
3. Task breakdown table (#, task, files, acceptance criteria)
4. Taste constraints (reference from principles.md)
5. Notes (assumptions, open questions)

After generating the plan, append to .duo/coordination/progress-log.md:
[$(date '+%Y-%m-%d %H:%M')] [planner] [PLAN_CREATED] Plan generated for: ${INTENT}"

PLAN_FILE="${DUO_DIR}/plans/plan.md"
if [[ -f "$PLAN_FILE" ]]; then
    echo ""
    echo -e "${BLUE}✓ Plan generated${NC}"
    echo "───────────────────────────────────"
    echo -e "Plan saved to: ${YELLOW}${PLAN_FILE}${NC}"
    echo ""
    echo "Preview:"
    echo "────────────────────────────────---"
    head -40 "$PLAN_FILE"
else
    echo -e "${RED}Error: Plan file was not created${NC}"
    exit 1
fi
