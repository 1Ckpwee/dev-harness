#!/usr/bin/env bash
# harness-init.sh — Bootstrap .harness/ in any project directory
# Usage: harness init [project_dir]
#        harness init .
#        harness init ~/my-project

set -euo pipefail

HARNESS_HOME="${HARNESS_HOME:-${HOME}/.dev-harness}"
TEMPLATE_DIR="${HARNESS_HOME}/templates"
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
HARNESS_DIR="${TARGET_DIR}/.harness"

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

echo -e "${BLUE}=== Dev Harness Init ===${NC}"
echo -e "Target: ${TARGET_DIR}"

# Check if already initialized
if [[ -d "$HARNESS_DIR" ]]; then
    echo -e "${YELLOW}Warning: .harness/ already exists at ${HARNESS_DIR}${NC}"
    read -p "Overwrite templates? (existing handoffs/reviews will be kept) [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create directory structure
echo -e "${GREEN}Creating .harness/ structure...${NC}"
mkdir -p "${HARNESS_DIR}"/{roles,coordination,quality,taste,handoffs,reviews}

# Copy templates
echo -e "${GREEN}Copying templates...${NC}"
cp "${TEMPLATE_DIR}/roles/builder-brief.md" "${HARNESS_DIR}/roles/"
cp "${TEMPLATE_DIR}/roles/reviewer-brief.md" "${HARNESS_DIR}/roles/"
cp "${TEMPLATE_DIR}/coordination/context-map.md" "${HARNESS_DIR}/coordination/"
cp "${TEMPLATE_DIR}/coordination/task-board.md" "${HARNESS_DIR}/coordination/"
cp "${TEMPLATE_DIR}/coordination/progress-log.md" "${HARNESS_DIR}/coordination/"
cp "${TEMPLATE_DIR}/quality/review-checklist.md" "${HARNESS_DIR}/quality/"
cp "${TEMPLATE_DIR}/quality/execution-strategy.md" "${HARNESS_DIR}/quality/"
cp "${TEMPLATE_DIR}/quality/output-format.md" "${HARNESS_DIR}/quality/"
cp "${TEMPLATE_DIR}/taste/principles.md" "${HARNESS_DIR}/taste/"

# Replace placeholders in context-map (cross-platform sed)
PROJECT_NAME=$(basename "$TARGET_DIR")
DATE=$(date '+%Y-%m-%d')
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/{DATE}/${DATE}/g" "${HARNESS_DIR}/coordination/context-map.md"
    sed -i '' "s/{PROJECT_NAME}/${PROJECT_NAME}/g" "${HARNESS_DIR}/coordination/context-map.md"
else
    sed -i "s/{DATE}/${DATE}/g" "${HARNESS_DIR}/coordination/context-map.md"
    sed -i "s/{PROJECT_NAME}/${PROJECT_NAME}/g" "${HARNESS_DIR}/coordination/context-map.md"
fi

# Ensure .harness/ is in project .gitignore (never push to remote)
PROJECT_GITIGNORE="${TARGET_DIR}/.gitignore"
if [[ -f "$PROJECT_GITIGNORE" ]]; then
    if ! grep -q '\.harness/' "$PROJECT_GITIGNORE" 2>/dev/null; then
        echo "" >> "$PROJECT_GITIGNORE"
        echo "# Dev Harness (local only)" >> "$PROJECT_GITIGNORE"
        echo ".harness/" >> "$PROJECT_GITIGNORE"
        echo -e "${GREEN}Added .harness/ to existing .gitignore${NC}"
    fi
else
    printf '# Dev Harness (local only)\n.harness/\n' > "$PROJECT_GITIGNORE"
    echo -e "${GREEN}Created .gitignore with .harness/ exclusion${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}=== Harness Initialized ===${NC}"
echo -e "Location: ${HARNESS_DIR}"
echo ""
echo "  .harness/"
echo "  ├── roles/           # Agent role definitions"
echo "  ├── coordination/    # Task board, context map, progress log"
echo "  ├── quality/         # Review checklist, execution strategy"
echo "  ├── taste/           # Your engineering principles"
echo "  ├── handoffs/        # Builder → Reviewer handoff files"
echo "  └── reviews/         # Reviewer feedback files"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit .harness/coordination/context-map.md — map your codebase"
echo "  2. Edit .harness/taste/principles.md — inject your preferences"
echo "  3. Add tasks to .harness/coordination/task-board.md"
echo "  4. Run: harness build   (start Claude Code as Builder)"
echo "  5. Run: harness review  (start Codex as Reviewer)"
