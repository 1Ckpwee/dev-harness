#!/usr/bin/env bash
# uninstall.sh — Remove duo-dev from this machine
# Usage: ./uninstall.sh
#        duo uninstall

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DUO_HOME="${HOME}/.duo-dev"
BIN_DIR="${HOME}/.local/bin"

echo -e "${BLUE}=== Uninstalling Duo Dev ===${NC}"
echo ""

# Confirm
read -p "This will remove duo-dev CLI and global config. Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Remove CLI symlink
if [[ -L "${BIN_DIR}/duo" ]]; then
    rm "${BIN_DIR}/duo"
    echo -e "${GREEN}Removed CLI symlink${NC}"
fi

# Remove duo-dev home directory
if [[ -d "$DUO_HOME" ]]; then
    rm -rf "$DUO_HOME"
    echo -e "${GREEN}Removed ${DUO_HOME}${NC}"
fi

# Clean Claude Code config
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]] && grep -q "Duo Dev" "$CLAUDE_MD" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/^## Duo Dev Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CLAUDE_MD"
        sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
    else
        sed -i '/^## Duo Dev Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CLAUDE_MD"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
    fi
    echo -e "${GREEN}Cleaned Claude Code config${NC}"
fi

# Clean Codex config
CODEX_AGENTS="${HOME}/.codex/AGENTS.md"
if [[ -f "$CODEX_AGENTS" ]] && grep -q "Duo Dev" "$CODEX_AGENTS" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/^## Duo Dev Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CODEX_AGENTS"
        sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CODEX_AGENTS"
    else
        sed -i '/^## Duo Dev Workflow$/,/^## [^D]/{/^## [^D]/!d;}' "$CODEX_AGENTS"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CODEX_AGENTS"
    fi
    echo -e "${GREEN}Cleaned Codex config${NC}"
fi

# Remove Cursor rule
CURSOR_RULE="${HOME}/.cursor/rules/duo-dev.mdc"
if [[ -f "$CURSOR_RULE" ]]; then
    rm "$CURSOR_RULE"
    echo -e "${GREEN}Removed Cursor rule${NC}"
fi

# Clean global gitignore
GLOBAL_GITIGNORE="${HOME}/.config/git/ignore"
if [[ -f "$GLOBAL_GITIGNORE" ]] && grep -q '\.duo/' "$GLOBAL_GITIGNORE" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/# Duo Dev/d;/\.duo\//d' "$GLOBAL_GITIGNORE"
    else
        sed -i '/# Duo Dev/d;/\.duo\//d' "$GLOBAL_GITIGNORE"
    fi
    echo -e "${GREEN}Cleaned global gitignore${NC}"
fi

echo ""
echo -e "${BLUE}=== Uninstall Complete ===${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Per-project .duo/ directories were NOT removed."
echo "To remove them manually: rm -rf /path/to/project/.duo/"
