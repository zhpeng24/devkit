#!/usr/bin/env bash
# Devkit installer — supports all major AI coding platforms
# Usage: ./install.sh [claude|cursor|copilot|codex|opencode|gemini]
#        ./install.sh            (interactive menu)
#        curl -fsSL <raw-url>/install.sh | bash -s -- claude

# Wrap everything in main() so bash must fully parse the script before executing.
# This prevents partial-download attacks when using `curl | bash`.
main() {

set -euo pipefail

REPO_URL="https://github.com/zhpeng24/devkit.git"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { printf '%b\n' "${BLUE}▸${NC} $*"; }
success() { printf '%b\n' "${GREEN}✔${NC} $*"; }
warn()    { printf '%b\n' "${YELLOW}⚠${NC} $*"; }
error()   { printf '%b\n' "${RED}✖${NC} $*" >&2; exit 1; }

# --- Core: clone or update ---
clone_or_update() {
    local dest="$1"
    if [[ -d "$dest/.git" ]]; then
        info "Already installed at ${BOLD}$dest${NC}, updating…"
        git -C "$dest" pull --ff-only --quiet
        success "Updated to latest version"
    else
        info "Cloning devkit to ${BOLD}$dest${NC}…"
        mkdir -p "$(dirname "$dest")"
        git clone --quiet "$REPO_URL" "$dest"
        success "Cloned successfully"
    fi
}

# --- Platform installers ---

install_claude() {
    printf '\n%b\n\n' "${BOLD}Claude Code${NC}"

    if command -v claude &>/dev/null; then
        info "Adding devkit marketplace…"
        claude plugins marketplace add "$REPO_URL" 2>/dev/null \
            && success "Marketplace added" \
            || warn "Marketplace may already be configured"

        info "Installing devkit plugin…"
        claude plugins install devkit 2>/dev/null \
            && success "Plugin installed" \
            || warn "Auto-install failed. Run manually:
  claude plugins marketplace add $REPO_URL
  claude plugins install devkit"
    else
        warn "claude CLI not found. After installing Claude Code, run:"
        printf '  %b\n' "${BOLD}claude plugins marketplace add $REPO_URL${NC}"
        printf '  %b\n' "${BOLD}claude plugins install devkit${NC}"
    fi

    success "Claude Code — done! Restart Claude Code to load the plugin."
}

install_cursor() {
    printf '\n%b\n\n' "${BOLD}Cursor${NC}"
    local dest="$HOME/.cursor/plugins/local/devkit"
    clone_or_update "$dest"
    success "Cursor — done! Restart Cursor to detect the plugin."
}

install_copilot() {
    printf '\n%b\n\n' "${BOLD}GitHub Copilot CLI${NC}"
    local dest="$HOME/.copilot/plugins/devkit"
    clone_or_update "$dest"

    if command -v copilot &>/dev/null; then
        info "Registering plugin with Copilot CLI…"
        copilot plugin install "$dest" 2>/dev/null \
            && success "Plugin registered" \
            || warn "Auto-registration failed. Run manually:
  copilot plugin install $dest"
    else
        warn "copilot CLI not found. After installing Copilot CLI, run:"
        printf '  %b\n' "${BOLD}copilot plugin install $dest${NC}"
    fi

    success "GitHub Copilot CLI — done!"
}

install_codex() {
    printf '\n%b\n\n' "${BOLD}Codex${NC}"
    local dest="$HOME/.codex/devkit"
    local skills_dir="$HOME/.agents/skills"
    local link="$skills_dir/devkit"

    clone_or_update "$dest"

    if [[ -L "$link" ]]; then
        info "Skills symlink already exists"
    elif [[ -e "$link" ]]; then
        warn "$link already exists but is not a symlink — skipping"
    else
        info "Creating skills symlink…"
        mkdir -p "$skills_dir"
        ln -s "$dest/skills" "$link"
        success "Symlink: $link → $dest/skills"
    fi

    success "Codex — done! Restart Codex to discover skills."
}

install_opencode() {
    printf '\n%b\n\n' "${BOLD}OpenCode${NC}"
    info "OpenCode uses a git URL — no local clone needed."
    echo ""
    echo "  Add to your opencode.json (global or project-level):"
    echo ""
    printf '  %b\n' "${BOLD}{${NC}"
    printf '  %b\n' "${BOLD}  \"plugin\": [\"devkit@git+$REPO_URL\"]${NC}"
    printf '  %b\n' "${BOLD}}${NC}"
    echo ""
    success "After editing, restart OpenCode to auto-install."
}

install_gemini() {
    printf '\n%b\n\n' "${BOLD}Gemini CLI${NC}"
    if command -v gemini &>/dev/null; then
        info "Installing Gemini CLI extension…"
        gemini extensions install "$REPO_URL" \
            && success "Gemini CLI — done!" \
            || warn "Installation failed. Run manually:
  gemini extensions install $REPO_URL"
    else
        warn "gemini CLI not found. After installing Gemini CLI, run:"
        printf '  %b\n' "${BOLD}gemini extensions install $REPO_URL${NC}"
    fi
}

# --- Interactive menu ---
show_menu() {
    # Refuse to run interactively when stdin is not a terminal (e.g. curl | bash)
    if [[ ! -t 0 ]]; then
        error "Interactive menu requires a terminal.
  Usage: curl -fsSL <url>/install.sh | bash -s -- <platform>
  Platforms: claude, cursor, copilot, codex, opencode, gemini"
    fi

    echo ""
    printf '%b\n' "${BOLD}  Devkit Installer${NC}"
    echo ""
    echo "  1) Claude Code"
    echo "  2) Cursor"
    echo "  3) GitHub Copilot CLI"
    echo "  4) Codex"
    echo "  5) OpenCode"
    echo "  6) Gemini CLI"
    echo ""
    echo "  0) Exit"
    echo ""
    read -rp "  Select platform [0-6]: " choice

    case "$choice" in
        1) install_claude   ;;
        2) install_cursor   ;;
        3) install_copilot  ;;
        4) install_codex    ;;
        5) install_opencode ;;
        6) install_gemini   ;;
        0) echo "Bye!"; exit 0 ;;
        *) error "Invalid choice" ;;
    esac
}

# --- Entrypoint ---
case "${1:-}" in
    claude)   install_claude   ;;
    cursor)   install_cursor   ;;
    copilot)  install_copilot  ;;
    codex)    install_codex    ;;
    opencode) install_opencode ;;
    gemini)   install_gemini   ;;
    "")       show_menu        ;;
    -h|--help)
        echo "Usage: $0 [claude|cursor|copilot|codex|opencode|gemini]"
        echo "       $0            (interactive menu)"
        ;;
    *)
        error "Unknown platform. Use: claude, cursor, copilot, codex, opencode, gemini"
        ;;
esac

} # end main — do not remove; protects against partial-download execution
main "$@"
