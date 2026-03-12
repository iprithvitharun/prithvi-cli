#!/usr/bin/env zsh
# Claude Code integration

__pmux_claude() {
  local prompt="${1// /}"

  # Check if Claude Code is installed
  if ! command -v claude &>/dev/null; then
    __pmux_error "Claude Code is not installed"
    __pmux_info "Install it with: ${PMUX_PINK}npm install -g @anthropic-ai/claude-code${PMUX_RESET}"
    return 1
  fi

  if [[ -z "$prompt" ]]; then
    # Launch interactive Claude Code
    __pmux_info "Launching ${PMUX_PINK}Claude Code${PMUX_RESET}..."
    command claude
  else
    # Pass prompt directly
    command claude "$prompt"
  fi
}
