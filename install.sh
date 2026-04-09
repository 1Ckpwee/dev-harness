#!/usr/bin/env bash
# install.sh — Install duo-dev globally
# Usage: ./install.sh
#        curl -fsSL https://raw.githubusercontent.com/1Ckpwee/duo-dev/main/install.sh | bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DUO_HOME="${HOME}/.duo-dev"
BIN_DIR="${HOME}/.local/bin"
REPO_URL="https://github.com/1Ckpwee/duo-dev.git"

# Detect if running from a cloned repo or via curl pipe
detect_source() {
    local script_dir
    # When piped from curl, $0 is "bash" and BASH_SOURCE is unset/empty
    if [[ -z "${BASH_SOURCE[0]:-}" ]] || [[ "${BASH_SOURCE[0]}" == "bash" ]]; then
        echo "remote"
    else
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [[ -d "${script_dir}/templates" && -d "${script_dir}/scripts" ]]; then
            echo "local:${script_dir}"
        else
            echo "remote"
        fi
    fi
}

SOURCE=$(detect_source)

if [[ "$SOURCE" == "remote" ]]; then
    echo -e "${BLUE}=== Installing Duo Dev (remote) ===${NC}"

    # Check git is available
    if ! command -v git &>/dev/null; then
        echo -e "${RED}Error: git is required but not installed.${NC}"
        exit 1
    fi

    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    echo -e "${GREEN}Cloning duo-dev...${NC}"
    git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR"
    REPO_DIR="$TMPDIR"
else
    REPO_DIR="${SOURCE#local:}"
    echo -e "${BLUE}=== Installing Duo Dev (local) ===${NC}"
fi

# Copy templates
mkdir -p "$DUO_HOME"
cp -r "${REPO_DIR}/templates" "$DUO_HOME/"
echo -e "${GREEN}Templates installed to ${DUO_HOME}/templates${NC}"

# Copy scripts
mkdir -p "$DUO_HOME/scripts"
cp "${REPO_DIR}/scripts/"* "$DUO_HOME/scripts/"
chmod +x "$DUO_HOME/scripts/"*
echo -e "${GREEN}Scripts installed to ${DUO_HOME}/scripts${NC}"

# Copy integrations
mkdir -p "$DUO_HOME/integrations"
cp "${REPO_DIR}/integrations/"* "$DUO_HOME/integrations/"
echo -e "${GREEN}Integrations installed to ${DUO_HOME}/integrations${NC}"

# Symlink duo CLI to PATH
mkdir -p "$BIN_DIR"
ln -sf "$DUO_HOME/scripts/duo" "$BIN_DIR/duo"
echo -e "${GREEN}CLI linked to ${BIN_DIR}/duo${NC}"

# Check PATH
if ! echo "$PATH" | tr ':' '\n' | grep -q "${BIN_DIR}"; then
    echo ""
    echo -e "${YELLOW}Add this to your shell profile (~/.zshrc or ~/.bashrc):${NC}"
    echo "  export PATH=\"\${HOME}/.local/bin:\${PATH}\""
fi

# Add .duo/ to global gitignore
GLOBAL_GITIGNORE="${HOME}/.config/git/ignore"
mkdir -p "$(dirname "$GLOBAL_GITIGNORE")"
if [[ -f "$GLOBAL_GITIGNORE" ]]; then
    if ! grep -q '\.duo/' "$GLOBAL_GITIGNORE" 2>/dev/null; then
        echo "" >> "$GLOBAL_GITIGNORE"
        echo "# Duo Dev (local only)" >> "$GLOBAL_GITIGNORE"
        echo ".duo/" >> "$GLOBAL_GITIGNORE"
    fi
else
    printf '# Duo Dev (local only)\n.duo/\n' > "$GLOBAL_GITIGNORE"
fi
git config --global core.excludesfile "$GLOBAL_GITIGNORE"
echo -e "${GREEN}.duo/ added to global gitignore${NC}"

# Install Claude Code integration
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
if [[ -d "${HOME}/.claude" ]]; then
    if [[ -f "$CLAUDE_MD" ]]; then
        if ! grep -q "Duo Dev" "$CLAUDE_MD" 2>/dev/null; then
            echo "" >> "$CLAUDE_MD"
            cat "${DUO_HOME}/integrations/claude-code.md" >> "$CLAUDE_MD"
            echo -e "${GREEN}Claude Code config updated${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Claude Code not found — skip config${NC}"
fi

# Install Codex integration
CODEX_AGENTS="${HOME}/.codex/AGENTS.md"
if [[ -d "${HOME}/.codex" ]]; then
    if ! grep -q "Duo Dev" "$CODEX_AGENTS" 2>/dev/null; then
        echo "" >> "$CODEX_AGENTS"
        cat "${DUO_HOME}/integrations/codex-agents.md" >> "$CODEX_AGENTS"
        echo -e "${GREEN}Codex config updated${NC}"
    fi
else
    echo -e "${YELLOW}Codex not found — skip config${NC}"
fi

# Install Cursor integration
CURSOR_RULES="${HOME}/.cursor/rules"
if [[ -d "${HOME}/.cursor" ]]; then
    mkdir -p "$CURSOR_RULES"
    if [[ ! -f "${CURSOR_RULES}/duo-dev.mdc" ]]; then
        cp "${DUO_HOME}/integrations/cursor-rule.mdc" "${CURSOR_RULES}/duo-dev.mdc" 2>/dev/null || true
        echo -e "${GREEN}Cursor rules installed${NC}"
    fi
else
    echo -e "${YELLOW}Cursor not found — skip config${NC}"
fi

echo ""
echo -e "${BLUE}=== Installation Complete ===${NC}"
echo ""
echo "Usage:"
echo "  duo init ~/my-project    # Initialize a project"
echo "  cd ~/my-project"
echo "  duo build                # Run Claude Code as Builder"
echo "  duo review               # Run Codex as Reviewer"
echo "  duo loop                 # Full build→review cycle"
echo "  duo uninstall            # Remove duo-dev"
