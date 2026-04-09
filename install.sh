#!/usr/bin/env bash
# install.sh — Install dev-harness globally
# Usage: ./install.sh
#        curl -fsSL https://raw.githubusercontent.com/1Ckpwee/dev-harness/main/install.sh | bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS_HOME="${HOME}/.dev-harness"
BIN_DIR="${HOME}/.local/bin"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Installing Dev Harness ===${NC}"

# Copy templates
mkdir -p "$HARNESS_HOME"
cp -r "${REPO_DIR}/templates" "$HARNESS_HOME/"
echo -e "${GREEN}Templates installed to ${HARNESS_HOME}/templates${NC}"

# Copy scripts
mkdir -p "$HARNESS_HOME/scripts"
cp "${REPO_DIR}/scripts/"* "$HARNESS_HOME/scripts/"
chmod +x "$HARNESS_HOME/scripts/"*
echo -e "${GREEN}Scripts installed to ${HARNESS_HOME}/scripts${NC}"

# Symlink harness CLI to PATH
mkdir -p "$BIN_DIR"
ln -sf "$HARNESS_HOME/scripts/harness" "$BIN_DIR/harness"
echo -e "${GREEN}CLI linked to ${BIN_DIR}/harness${NC}"

# Check PATH
if ! echo "$PATH" | tr ':' '\n' | grep -q "${BIN_DIR}"; then
    echo ""
    echo -e "${YELLOW}Add this to your shell profile (~/.zshrc or ~/.bashrc):${NC}"
    echo "  export PATH=\"\${HOME}/.local/bin:\${PATH}\""
fi

# Add .harness/ to global gitignore
GLOBAL_GITIGNORE="${HOME}/.config/git/ignore"
mkdir -p "$(dirname "$GLOBAL_GITIGNORE")"
if [[ -f "$GLOBAL_GITIGNORE" ]]; then
    if ! grep -q '\.harness/' "$GLOBAL_GITIGNORE" 2>/dev/null; then
        echo "" >> "$GLOBAL_GITIGNORE"
        echo "# Dev Harness (local only)" >> "$GLOBAL_GITIGNORE"
        echo ".harness/" >> "$GLOBAL_GITIGNORE"
    fi
else
    printf '# Dev Harness (local only)\n.harness/\n' > "$GLOBAL_GITIGNORE"
fi
git config --global core.excludesfile "$GLOBAL_GITIGNORE"
echo -e "${GREEN}.harness/ added to global gitignore${NC}"

# Install Claude Code integration
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
if [[ -d "${HOME}/.claude" ]]; then
    if [[ -f "$CLAUDE_MD" ]]; then
        if ! grep -q "Dev Harness" "$CLAUDE_MD" 2>/dev/null; then
            cat >> "$CLAUDE_MD" << 'EOF'

## Dev Harness Workflow
When a project contains a `.harness/` directory, this project uses the dual-agent workflow:
- **Claude Code** = Builder agent (executes tasks, writes code, generates handoffs)
- **Codex** = Reviewer agent (reviews handoffs, grades quality, catches errors)
- **Cursor** = IDE-integrated Builder (same role as Claude Code, different interface)

### Builder Mode (when you see `.harness/`)
1. Read `.harness/roles/builder-brief.md` for your full role definition
2. Pick tasks from `.harness/coordination/task-board.md`
3. Follow `.harness/taste/principles.md` as binding constraints
4. Generate handoff files in `.harness/handoffs/` when completing work
5. Update `progress-log.md` and `task-board.md` after every significant action

### CLI Shortcut
- `harness init <dir>` — bootstrap .harness/ in any project
- `harness build` — launch Claude Code as Builder
- `harness review` — launch Codex as Reviewer
- `harness loop` — run one full build→review cycle
EOF
            echo -e "${GREEN}Claude Code config updated${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Claude Code not found — skip config${NC}"
fi

# Install Codex integration
CODEX_AGENTS="${HOME}/.codex/AGENTS.md"
if [[ -d "${HOME}/.codex" ]]; then
    if ! grep -q "Dev Harness" "$CODEX_AGENTS" 2>/dev/null; then
        cat >> "$CODEX_AGENTS" << 'EOF'

## Dev Harness Workflow
When a project contains a `.harness/` directory, you are the **Reviewer/Architect** agent in a dual-agent workflow.

### Reviewer Mode (when you see `.harness/`)
1. Read `.harness/roles/reviewer-brief.md` for your full role definition
2. Find the latest handoff file in `.harness/handoffs/`
3. Grade against `.harness/quality/review-checklist.md`
4. Follow `.harness/taste/principles.md` as the human's binding quality standards
5. Output review files to `.harness/reviews/`
6. Update `progress-log.md` and `task-board.md` with your findings
EOF
        echo -e "${GREEN}Codex config updated${NC}"
    fi
else
    echo -e "${YELLOW}Codex not found — skip config${NC}"
fi

# Install Cursor integration
CURSOR_RULES="${HOME}/.cursor/rules"
if [[ -d "${HOME}/.cursor" ]]; then
    mkdir -p "$CURSOR_RULES"
    if [[ ! -f "${CURSOR_RULES}/dev-harness.mdc" ]]; then
        cp "${REPO_DIR}/integrations/cursor-rule.mdc" "${CURSOR_RULES}/dev-harness.mdc" 2>/dev/null || true
        echo -e "${GREEN}Cursor rules installed${NC}"
    fi
else
    echo -e "${YELLOW}Cursor not found — skip config${NC}"
fi

echo ""
echo -e "${BLUE}=== Installation Complete ===${NC}"
echo ""
echo "Usage:"
echo "  harness init ~/my-project    # Initialize a project"
echo "  cd ~/my-project"
echo "  harness build                # Run Claude Code as Builder"
echo "  harness review               # Run Codex as Reviewer"
echo "  harness loop                 # Full build→review cycle"
