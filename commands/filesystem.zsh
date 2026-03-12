#!/usr/bin/env zsh
# Filesystem commands — human-friendly wrappers

__prithvi_goto() {
  local target="${1// /}"
  if [[ -z "$target" ]]; then
    __prithvi_ask "Where to?"
    read target
  fi

  if [[ -d "$target" ]]; then
    cd "$target"
    __prithvi_success "Now in ${PRITHVI_CYAN}$(basename "$PWD")${PRITHVI_RESET}"
  else
    __prithvi_error "Directory not found: ${PRITHVI_DIM}$target${PRITHVI_RESET}"
    return 1
  fi
}

__prithvi_goback() {
  cd ..
  __prithvi_success "Now in ${PRITHVI_CYAN}$(basename "$PWD")${PRITHVI_RESET}"
}

__prithvi_gohome() {
  cd ~
  __prithvi_success "Now in ${PRITHVI_CYAN}~${PRITHVI_RESET}"
}

__prithvi_showfiles() {
  local target="${1// /}"
  print ""
  if [[ -n "$target" ]]; then
    command ls -1 "$target"
  else
    command ls -1
  fi
  print ""
}

__prithvi_open() {
  local file="$1"
  if [[ -z "$file" ]]; then
    __prithvi_ask "Which file?"
    read file
  fi

  if [[ -f "$file" ]]; then
    command cat "$file"
  elif [[ -d "$file" ]]; then
    __prithvi_info "That's a directory. Showing files instead:"
    __prithvi_showfiles "$file"
  else
    __prithvi_error "File not found: ${PRITHVI_DIM}$file${PRITHVI_RESET}"
    return 1
  fi
}

__prithvi_newfolder() {
  local name="$1"
  if [[ -z "$name" ]]; then
    __prithvi_ask "Folder name?"
    read name
  fi

  command mkdir -p "$name"
  __prithvi_success "Created folder ${PRITHVI_CYAN}$name${PRITHVI_RESET}"
}

__prithvi_newfile() {
  local name="$1"
  if [[ -z "$name" ]]; then
    __prithvi_ask "File name?"
    read name
  fi

  command touch "$name"
  __prithvi_success "Created file ${PRITHVI_CYAN}$name${PRITHVI_RESET}"
}

__prithvi_whereami() {
  __prithvi_info "${PRITHVI_CYAN}$PWD${PRITHVI_RESET}"
}
