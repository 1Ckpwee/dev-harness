#!/usr/bin/env bash
# uninstall.sh — Remove dev-harness from this machine
# Usage: ./uninstall.sh
#        harness uninstall

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

HARNESS_HOME="${HOME}/.dev-harness"
BIN_DIR="${HOME}/.local/bin"

echo -e "${BLUE}=== Uninstalling Dev Harness ===${NC}"
echo ""

# Confirm
read -p "This will remove dev-harness CLI and global config. Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Remove CLI symlink
if [[ -L "${BIN_DIR}/harness" ]]; then
    rm "${BIN_DIR}/harness"
    echo -e "${GREEN}Removed CLI symlink${NC}"
fi

# Remove harness home directory
if [[ -d "$HARNESS_HOME" ]]; then
    rm -rf "$HARNESS_HOME"
    echo -e "${GREEN}Removed ${HARNESS_HOME}${NC}"
fi

# Clean Claude Code config
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]] && grep -q "Dev Harness" "$CLAUDE_MD" 2>/dev/null; then
    # Remove the Dev Harness section (from "## Dev Harness" to the next "##" or EOF)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/^## Dev Harness Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CLAUDE_MD"
        # Also remove trailing blank lines left behind
        sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
    else
        sed -i '/^## Dev Harness Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CLAUDE_MD"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
    fi
    echo -e "${GREEN}Cleaned Claude Code config${NC}"
fi

# Clean Codex config
CODEX_AGENTS="${HOME}/.codex/AGENTS.md"
if [[ -f "$CODEX_AGENTS" ]] && grep -q "Dev Harness" "$CODEX_AGENTS" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/^## Dev Harness Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CODEX_AGENTS"
        sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CODEX_AGENTS"
    else
        sed -i '/^## Dev Harness Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CODEX_AGENTS"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CODEX_AGENTS"
    fi
    echo -e "${GREEN}Cleaned Codex config${NC}"
fi

# Remove Cursor rule
CURSOR_RULE="${HOME}/.cursor/rules/dev-harness.mdc"
if [[ -f "$CURSOR_RULE" ]]; then
    rm "$CURSOR_RULE"
    echo -e "${GREEN}Removed Cursor rule${NC}"
fi

# Clean global gitignore
GLOBAL_GITIGNORE="${HOME}/.config/git/ignore"
if [[ -f "$GLOBAL_GITIGNORE" ]] && grep -q '\.harness/' "$GLOBAL_GITIGNORE" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/# Dev Harness/d;/\.harness\//d' "$GLOBAL_GITIGNORE"
    else
        sed -i '/# Dev Harness/d;/\.harness\//d' "$GLOBAL_GITIGNORE"
    fi
    echo -e "${GREEN}Cleaned global gitignore${NC}"
fi

echo ""
echo -e "${BLUE}=== Uninstall Complete ===${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Per-project .harness/ directories were NOT removed."
echo "To remove them manually: rm -rf /path/to/project/.harness/"
