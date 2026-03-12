#!/usr/bin/env zsh
# Clean, minimal prompt: directory + git branch

__prithvi_git_prompt() {
  local branch
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null) || return
  echo " %{$PRITHVI_PINK%}$branch%{$PRITHVI_RESET%}"
}

setopt PROMPT_SUBST
PROMPT=' %{$PRITHVI_CYAN%}%~%{$PRITHVI_RESET%}$(__prithvi_git_prompt) %{$PRITHVI_PINK%}❯%{$PRITHVI_RESET%} '

# ── Report current directory to terminal (OSC 7) ────────────
# Lets the terminal app track the working directory for new tab inheritance
__prithvi_report_cwd() {
  printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd __prithvi_report_cwd
__prithvi_report_cwd  # report initial directory

# ── History ──────────────────────────────────────────────────
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY        # append instead of overwrite
setopt SHARE_HISTORY         # share history across sessions
setopt HIST_IGNORE_DUPS      # skip consecutive duplicates
setopt HIST_IGNORE_SPACE     # skip commands starting with space
setopt HIST_REDUCE_BLANKS    # trim extra whitespace
