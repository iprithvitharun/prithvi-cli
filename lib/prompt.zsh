#!/usr/bin/env zsh
# Clean, minimal prompt: directory + git branch

__pmux_git_prompt() {
  local branch
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null) || return
  echo " %{$PMUX_PINK%}$branch%{$PMUX_RESET%}"
}

setopt PROMPT_SUBST
PROMPT=' %{$PMUX_CYAN%}%~%{$PMUX_RESET%}$(__pmux_git_prompt) %{$PMUX_PINK%}❯%{$PMUX_RESET%} '

# ── Report current directory to terminal (OSC 7) ────────────
# Lets the terminal app track the working directory for new tab inheritance
__pmux_report_cwd() {
  printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd __pmux_report_cwd
__pmux_report_cwd  # report initial directory

# ── History ──────────────────────────────────────────────────
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY        # append instead of overwrite
setopt SHARE_HISTORY         # share history across sessions
setopt HIST_IGNORE_DUPS      # skip consecutive duplicates
setopt HIST_IGNORE_SPACE     # skip commands starting with space
setopt HIST_REDUCE_BLANKS    # trim extra whitespace
