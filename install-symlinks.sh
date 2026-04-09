#!/usr/bin/env bash
# ==============================================================================
# Bee - Claude Code Symlinks Installer
# ==============================================================================
# Creates symlinks from ~/.claude/{agents,commands,skills} to the Bee repo,
# enabling all Bee agents, commands, and skills in your Claude Code environment.
#
# Usage:
#   bash install-symlinks.sh              # Auto-detects Bee repo from script location
#   bash install-symlinks.sh /path/to/bee # Explicit Bee repo path
#   bash install-symlinks.sh --remove      # Remove all Bee symlinks
#
# Requirements:
#   - Claude Code CLI installed
#   - Bee repository cloned locally
# ==============================================================================

set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Globals ---
CLAUDE_DIR="$HOME/.claude"
FACTORY_DIR="$HOME/.factory"
BEE_DIR=""
INSTALL_CLAUDE=true
INSTALL_FACTORY=false
CREATED=0
SKIPPED=0
ERRORS=0
REMOVED=0

# --- Functions ---

print_banner() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║        Bee - Claude Code Symlinks Installer     ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

log_info()    { echo -e "  ${BLUE}INFO${NC}    $1"; }
log_success() { echo -e "  ${GREEN}OK${NC}      $1"; }
log_skip()    { echo -e "  ${YELLOW}SKIP${NC}    $1"; }
log_error()   { echo -e "  ${RED}ERROR${NC}   $1"; }
log_section() { echo -e "\n  ${BOLD}${CYAN}── $1 ──${NC}\n"; }

resolve_bee_dir() {
  if [[ -n "${1:-}" && "$1" != "--remove" && "$1" != "--factory" && "$1" != "--all" && "$1" != "--claude" ]]; then
    BEE_DIR="$(cd "$1" && pwd)"
  else
    # Auto-detect from script location
    BEE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi

  # Validate Bee repo
  if [[ ! -f "$BEE_DIR/CLAUDE.md" ]]; then
    log_error "Not a Bee repository: $BEE_DIR"
    log_error "CLAUDE.md not found. Please provide the correct path."
    exit 1
  fi

  if [[ ! -d "$BEE_DIR/default/agents" ]]; then
    log_error "Missing default/agents directory in: $BEE_DIR"
    exit 1
  fi
}

create_directories() {
  local base_dirs=("agents" "commands" "skills")
  
  if [[ "$INSTALL_CLAUDE" == true ]]; then
    for subdir in "${base_dirs[@]}"; do
      local dir="$CLAUDE_DIR/$subdir"
      if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
      fi
    done
  fi
  
  if [[ "$INSTALL_FACTORY" == true ]]; then
    for subdir in "${base_dirs[@]}"; do
      local dir="$FACTORY_DIR/$subdir"
      if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
      fi
    done
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"
  local name
  name="$(basename "$target")"

  if [[ -L "$target" ]]; then
    local existing
    existing="$(readlink "$target")"
    if [[ "$existing" == "$source" ]]; then
      SKIPPED=$((SKIPPED + 1))
      return
    else
      # Symlink exists but points elsewhere - update it
      rm "$target"
      ln -s "$source" "$target"
      log_success "$name (updated)"
      CREATED=$((CREATED + 1))
      return
    fi
  elif [[ -e "$target" ]]; then
    log_error "$name already exists as a regular file (not a symlink). Skipping."
    ERRORS=$((ERRORS + 1))
    return
  fi

  ln -s "$source" "$target"
  CREATED=$((CREATED + 1))
}

link_agents() {
  local plugin="$1"
  local target_dir="$2"
  local agents_dir="$BEE_DIR/$plugin/agents"

  [[ ! -d "$agents_dir" ]] && return

  for agent in "$agents_dir"/*.md; do
    [[ ! -f "$agent" ]] && continue
    local name
    name="$(basename "$agent")"
    create_symlink "$agent" "$target_dir/agents/$name"
  done
}

link_commands() {
  local plugin="$1"
  local target_dir="$2"
  local commands_dir="$BEE_DIR/$plugin/commands"

  [[ ! -d "$commands_dir" ]] && return

  for cmd in "$commands_dir"/*.md; do
    [[ ! -f "$cmd" ]] && continue
    local name
    name="$(basename "$cmd")"
    create_symlink "$cmd" "$target_dir/commands/$name"
  done
}

link_skills() {
  local plugin="$1"
  local target_dir="$2"
  local skills_dir="$BEE_DIR/$plugin/skills"

  [[ ! -d "$skills_dir" ]] && return

  for skill in "$skills_dir"/*/; do
    [[ ! -d "$skill" ]] && continue
    local name
    name="$(basename "$skill")"
    # Skip shared-patterns directories (internal to each plugin, not standalone skills)
    [[ "$name" == "shared-patterns" ]] && continue
    create_symlink "$skill" "$target_dir/skills/$name"
  done
}

install_symlinks() {
  local plugins=("default" "dev-team" "pm-team" "pmo-team" "tw-team")

  for plugin in "${plugins[@]}"; do
    log_section "$plugin"
    if [[ "$INSTALL_CLAUDE" == true ]]; then
      link_agents "$plugin" "$CLAUDE_DIR"
      link_commands "$plugin" "$CLAUDE_DIR"
      link_skills "$plugin" "$CLAUDE_DIR"
    fi
    if [[ "$INSTALL_FACTORY" == true ]]; then
      link_agents "$plugin" "$FACTORY_DIR"
      link_commands "$plugin" "$FACTORY_DIR"
      link_skills "$plugin" "$FACTORY_DIR"
    fi
  done
}

remove_symlinks() {
  log_section "Removing Bee symlinks"

  for dir in agents commands skills; do
    local target_dir="$CLAUDE_DIR/$dir"
    [[ ! -d "$target_dir" ]] && continue

    for item in "$target_dir"/*; do
      [[ ! -L "$item" ]] && continue
      local link_target
      link_target="$(readlink "$item")"
      # Only remove symlinks that point to the Bee repo
      if [[ "$link_target" == *"/bee/"* ]]; then
        rm "$item"
        log_success "Removed: $dir/$(basename "$item")"
        REMOVED=$((REMOVED + 1))
      fi
    done
  done

  echo ""
  echo -e "  ${GREEN}${BOLD}Done!${NC} Removed ${REMOVED} symlinks."
}

print_summary() {
  echo ""
  echo -e "  ${BOLD}════════════════════════════════════════${NC}"
  echo -e "  ${GREEN}Created:${NC}  $CREATED symlinks"
  echo -e "  ${YELLOW}Skipped:${NC}  $SKIPPED (already correct)"
  if [[ $ERRORS -gt 0 ]]; then
    echo -e "  ${RED}Errors:${NC}   $ERRORS"
  fi
  echo -e "  ${BOLD}════════════════════════════════════════${NC}"
  echo ""
  echo -e "  ${CYAN}Bee repo:${NC}   $BEE_DIR"
  [[ "$INSTALL_CLAUDE" == true ]] && echo -e "  ${CYAN}Claude dir:${NC}  $CLAUDE_DIR"
  [[ "$INSTALL_FACTORY" == true ]] && echo -e "  ${CYAN}Factory dir:${NC} $FACTORY_DIR"
  echo ""

  local total=$((CREATED + SKIPPED))
  if [[ $total -gt 0 ]]; then
    local target_names=""
    [[ "$INSTALL_CLAUDE" == true ]] && target_names="Claude Code"
    [[ "$INSTALL_FACTORY" == true ]] && { [[ -n "$target_names" ]] && target_names="$target_names and Factory AI" || target_names="Factory AI"; }
    echo -e "  ${GREEN}${BOLD}Bee is ready!${NC} Open $target_names to use all skills, agents, and commands."
    echo ""
    echo -e "  Try these commands:"
    echo -e "    ${BOLD}/bee:brainstorm${NC}      - Socratic design refinement"
    echo -e "    ${BOLD}/bee:dev-cycle${NC}       - 10-gate development cycle"
    echo -e "    ${BOLD}/bee:pre-dev-feature${NC} - Lightweight pre-dev workflow"
    echo -e "    ${BOLD}/bee:codereview${NC}      - Parallel code review (6 reviewers)"
    echo ""
  fi
}

# --- Main ---

print_banner

if [[ "${1:-}" == "--remove" ]]; then
  resolve_bee_dir "${2:-}"
  remove_symlinks
  exit 0
fi

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "  Usage:"
  echo "    bash install-symlinks.sh              # Install for Claude Code (default)"
  echo "    bash install-symlinks.sh --factory    # Install for Factory AI"
  echo "    bash install-symlinks.sh --all        # Install for both Claude Code and Factory AI"
  echo "    bash install-symlinks.sh /path/to/bee # Explicit path"
  echo "    bash install-symlinks.sh --remove      # Remove Bee symlinks"
  echo ""
  exit 0
fi

if [[ "${1:-}" == "--factory" ]]; then
  INSTALL_CLAUDE=false
  INSTALL_FACTORY=true
  shift
elif [[ "${1:-}" == "--all" ]]; then
  INSTALL_CLAUDE=true
  INSTALL_FACTORY=true
  shift
fi

resolve_bee_dir "${1:-}"

log_info "Bee repo: $BEE_DIR"
[[ "$INSTALL_CLAUDE" == true ]] && log_info "Claude dir: $CLAUDE_DIR"
[[ "$INSTALL_FACTORY" == true ]] && log_info "Factory dir: $FACTORY_DIR"

create_directories
install_symlinks
print_summary
