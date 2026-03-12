#!/usr/bin/env zsh
# Git commands — interactive wrappers with pretty output

__pmux_git_status() {
  print ""
  __pmux_info "${PMUX_BOLD}Git Status${PMUX_RESET}"
  print ""
  command git status --short 2>/dev/null | while IFS= read -r line; do
    local status_code="${line:0:2}"
    local file="${line:3}"
    case "$status_code" in
      "??") print "  ${PMUX_RED}●${PMUX_RESET} ${PMUX_DIM}untracked${PMUX_RESET}  $file" ;;
      " M") print "  ${PMUX_YELLOW}●${PMUX_RESET} ${PMUX_DIM}modified${PMUX_RESET}   $file" ;;
      "M ")  print "  ${PMUX_GREEN}●${PMUX_RESET} ${PMUX_DIM}staged${PMUX_RESET}     $file" ;;
      "MM") print "  ${PMUX_YELLOW}●${PMUX_RESET} ${PMUX_DIM}partial${PMUX_RESET}    $file" ;;
      "A ")  print "  ${PMUX_GREEN}●${PMUX_RESET} ${PMUX_DIM}added${PMUX_RESET}      $file" ;;
      " D") print "  ${PMUX_RED}●${PMUX_RESET} ${PMUX_DIM}deleted${PMUX_RESET}    $file" ;;
      "D ")  print "  ${PMUX_GREEN}●${PMUX_RESET} ${PMUX_DIM}deleted${PMUX_RESET}    $file" ;;
      "R ")  print "  ${PMUX_BLUE}●${PMUX_RESET} ${PMUX_DIM}renamed${PMUX_RESET}    $file" ;;
      *)    print "  ${PMUX_GRAY}●${PMUX_RESET} ${PMUX_DIM}${status_code}${PMUX_RESET}  $file" ;;
    esac
  done

  local count=$(command git status --short 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -eq 0 ]]; then
    __pmux_success "Working tree is clean"
  else
    print ""
    __pmux_info "${count} file(s) changed"
  fi
  print ""
}

__pmux_git_save() {
  # Show what will be committed
  __pmux_git_status

  __pmux_ask "Commit message?"
  local msg
  read msg

  if [[ -z "$msg" ]]; then
    __pmux_error "Commit message cannot be empty"
    return 1
  fi

  command git add -A
  command git commit -m "$msg"

  if [[ $? -eq 0 ]]; then
    __pmux_success "Saved: ${PMUX_DIM}$msg${PMUX_RESET}"
  else
    __pmux_error "Commit failed"
    return 1
  fi
}

__pmux_git_push() {
  local branch=$(command git symbolic-ref --short HEAD 2>/dev/null)
  __pmux_info "Pushing ${PMUX_PINK}$branch${PMUX_RESET} to remote..."
  command git push -u origin "$branch" 2>&1
  if [[ $? -eq 0 ]]; then
    __pmux_success "Pushed to remote"
  else
    __pmux_error "Push failed"
    return 1
  fi
}

__pmux_git_pull() {
  __pmux_info "Pulling from remote..."
  command git pull 2>&1
  if [[ $? -eq 0 ]]; then
    __pmux_success "Up to date"
  else
    __pmux_error "Pull failed"
    return 1
  fi
}

__pmux_git_branch() {
  print ""
  __pmux_info "${PMUX_BOLD}Branches${PMUX_RESET}"
  print ""
  command git branch --list 2>/dev/null | while IFS= read -r line; do
    if [[ "$line" == "* "* ]]; then
      print "  ${PMUX_GREEN}●${PMUX_RESET} ${PMUX_BOLD}${line:2}${PMUX_RESET} ${PMUX_DIM}(current)${PMUX_RESET}"
    else
      print "  ${PMUX_GRAY}○${PMUX_RESET} ${line:2}"
    fi
  done
  print ""
}

__pmux_git_switch() {
  __pmux_git_branch
  __pmux_ask "Which branch?"
  local branch
  read branch

  if [[ -z "$branch" ]]; then
    __pmux_error "No branch specified"
    return 1
  fi

  command git checkout "$branch" 2>&1
  if [[ $? -eq 0 ]]; then
    __pmux_success "Switched to ${PMUX_PINK}$branch${PMUX_RESET}"
  else
    __pmux_error "Could not switch to ${PMUX_DIM}$branch${PMUX_RESET}"
    return 1
  fi
}

__pmux_git_new_branch() {
  __pmux_ask "Branch name?"
  local name
  read name

  if [[ -z "$name" ]]; then
    __pmux_error "Branch name cannot be empty"
    return 1
  fi

  command git checkout -b "$name" 2>&1
  if [[ $? -eq 0 ]]; then
    __pmux_success "Created and switched to ${PMUX_PINK}$name${PMUX_RESET}"
  else
    __pmux_error "Could not create branch ${PMUX_DIM}$name${PMUX_RESET}"
    return 1
  fi
}

__pmux_git_log() {
  command git log --oneline --graph --decorate --color -20 2>/dev/null
}

__pmux_git_undo() {
  local last_msg=$(command git log -1 --pretty=%s 2>/dev/null)
  __pmux_warn "This will undo the last commit: ${PMUX_DIM}$last_msg${PMUX_RESET}"
  __pmux_ask "Are you sure? (yes/no)"
  local confirm
  read confirm

  if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
    command git reset --soft HEAD~1
    __pmux_success "Undone. Changes are still staged."
  else
    __pmux_info "Cancelled"
  fi
}

__pmux_git_discard() {
  __pmux_git_status
  __pmux_warn "${PMUX_RED}This will discard ALL uncommitted changes.${PMUX_RESET}"
  __pmux_ask "Discard all changes? (yes/no)"
  local confirm
  read confirm

  if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
    command git checkout -- .
    command git clean -fd
    __pmux_success "All changes discarded"
  else
    __pmux_info "Cancelled"
  fi
}

__pmux_git_stash() {
  command git stash push -m "pmux-stash-$(date +%H:%M:%S)"
  if [[ $? -eq 0 ]]; then
    __pmux_success "Changes stashed"
  else
    __pmux_error "Nothing to stash"
  fi
}

__pmux_git_unstash() {
  command git stash pop
  if [[ $? -eq 0 ]]; then
    __pmux_success "Stashed changes restored"
  else
    __pmux_error "No stash to restore"
  fi
}

__pmux_git_diff() {
  command git diff --color 2>/dev/null
}
