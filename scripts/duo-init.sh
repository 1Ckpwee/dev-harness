#!/usr/bin/env bash
# duo-init.sh — Bootstrap .duo/ in any project directory
# Usage: duo init [project_dir]
#        duo init .
#        duo init ~/my-project

set -euo pipefail

DUO_HOME="${DUO_HOME:-${HOME}/.duo-dev}"
TEMPLATE_DIR="${DUO_HOME}/templates"
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DUO_DIR="${TARGET_DIR}/.duo"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check templates exist
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo -e "${RED}Error: Templates not found at ${TEMPLATE_DIR}${NC}"
    echo "Run the install script first: ./install.sh"
    exit 1
fi

echo -e "${BLUE}=== Duo Dev Init ===${NC}"
echo -e "Target: ${TARGET_DIR}"

# Check if already initialized
if [[ -d "$DUO_DIR" ]]; then
    echo -e "${YELLOW}Warning: .duo/ already exists at ${DUO_DIR}${NC}"
    read -p "Overwrite templates? (existing handoffs/reviews will be kept) [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create directory structure
echo -e "${GREEN}Creating .duo/ structure...${NC}"
mkdir -p "${DUO_DIR}"/{roles,coordination,quality,taste,handoffs,reviews,plans}

# Copy templates
echo -e "${GREEN}Copying templates...${NC}"
cp "${TEMPLATE_DIR}/roles/builder-brief.md" "${DUO_DIR}/roles/"
cp "${TEMPLATE_DIR}/roles/reviewer-brief.md" "${DUO_DIR}/roles/"
cp "${TEMPLATE_DIR}/roles/planner-brief.md" "${DUO_DIR}/roles/"
cp "${TEMPLATE_DIR}/roles/orchestrator-brief.md" "${DUO_DIR}/roles/"
cp "${TEMPLATE_DIR}/coordination/context-map.md" "${DUO_DIR}/coordination/"
cp "${TEMPLATE_DIR}/coordination/task-board.md" "${DUO_DIR}/coordination/"
cp "${TEMPLATE_DIR}/coordination/progress-log.md" "${DUO_DIR}/coordination/"
cp "${TEMPLATE_DIR}/quality/review-checklist.md" "${DUO_DIR}/quality/"
cp "${TEMPLATE_DIR}/quality/execution-strategy.md" "${DUO_DIR}/quality/"
cp "${TEMPLATE_DIR}/quality/output-format.md" "${DUO_DIR}/quality/"
cp "${TEMPLATE_DIR}/taste/principles.md" "${DUO_DIR}/taste/"

# Replace placeholders in context-map (cross-platform sed)
PROJECT_NAME=$(basename "$TARGET_DIR")
DATE=$(date '+%Y-%m-%d')
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/{DATE}/${DATE}/g" "${DUO_DIR}/coordination/context-map.md"
    sed -i '' "s/{PROJECT_NAME}/${PROJECT_NAME}/g" "${DUO_DIR}/coordination/context-map.md"
else
    sed -i "s/{DATE}/${DATE}/g" "${DUO_DIR}/coordination/context-map.md"
    sed -i "s/{PROJECT_NAME}/${PROJECT_NAME}/g" "${DUO_DIR}/coordination/context-map.md"
fi

# Ensure .duo/ is in project .gitignore (never push to remote)
PROJECT_GITIGNORE="${TARGET_DIR}/.gitignore"
if [[ -f "$PROJECT_GITIGNORE" ]]; then
    if ! grep -q '\.duo/' "$PROJECT_GITIGNORE" 2>/dev/null; then
        echo "" >> "$PROJECT_GITIGNORE"
        echo "# Duo Dev (local only)" >> "$PROJECT_GITIGNORE"
        echo ".duo/" >> "$PROJECT_GITIGNORE"
        echo -e "${GREEN}Added .duo/ to existing .gitignore${NC}"
    fi
else
    printf '# Duo Dev (local only)\n.duo/\n' > "$PROJECT_GITIGNORE"
    echo -e "${GREEN}Created .gitignore with .duo/ exclusion${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}=== Duo Initialized ===${NC}"
echo -e "Location: ${DUO_DIR}"
echo ""
echo "  .duo/"
echo "  ├── roles/           # Agent role definitions (Builder, Reviewer, Planner)"
echo "  ├── coordination/     # Task board, context map, progress log"
echo "  ├── quality/          # Review checklist, execution strategy"
echo "  ├── taste/            # Your engineering principles"
echo "  ├── plans/            # Generated plans (from duo plan)"
echo "  ├── handoffs/         # Builder → Reviewer handoff files"
echo "  └── reviews/          # Reviewer feedback files"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit .duo/taste/principles.md — inject your engineering preferences"
echo "  2. Run: duo context — auto-generate codebase map"
echo "  3. Run: duo plan \"实现登录功能\" — create a plan from intent"
echo "  4. Run: duo loop    — execute plan with Builder + Reviewer"
