#!/usr/bin/env zsh
# Filesystem commands — human-friendly wrappers

__pmux_goto() {
  local target="${1// /}"
  if [[ -z "$target" ]]; then
    __pmux_ask "Where to?"
    read target
  fi

  if [[ -d "$target" ]]; then
    cd "$target"
    __pmux_success "Now in ${PMUX_CYAN}$(basename "$PWD")${PMUX_RESET}"
  else
    __pmux_error "Directory not found: ${PMUX_DIM}$target${PMUX_RESET}"
    return 1
  fi
}

__pmux_goback() {
  cd ..
  __pmux_success "Now in ${PMUX_CYAN}$(basename "$PWD")${PMUX_RESET}"
}

__pmux_gohome() {
  cd ~
  __pmux_success "Now in ${PMUX_CYAN}~${PMUX_RESET}"
}

__pmux_showfiles() {
  local target="${1// /}"
  local dir="${target:-.}"
  local -a entries

  # Collect directory entries (dirs first, then files)
  local -a dirs files
  for f in "$dir"/*(N); do
    local name="${f:t}"
    if [[ -d "$f" ]]; then
      dirs+=("$name")
    else
      files+=("$name")
    fi
  done
  entries=("${dirs[@]}" "${files[@]}")

  if (( ${#entries} == 0 )); then
    __pmux_info "Empty directory"
    return
  fi

  # Run interactive picker
  local selection
  selection=$(__pmux_picker "${entries[@]}")
  local ret=$?

  if (( ret == 0 )) && [[ -n "$selection" ]]; then
    local full_path="${dir}/${selection}"
    if [[ -d "$full_path" ]]; then
      cd "$full_path"
      __pmux_success "Now in ${PMUX_CYAN}$(basename "$PWD")${PMUX_RESET}"
    elif [[ -f "$full_path" ]]; then
      __pmux_info "File: ${PMUX_CYAN}${selection}${PMUX_RESET} ($(wc -c < "$full_path" | tr -d ' ') bytes)"
    fi
  fi
}

__pmux_open() {
  local file="$1"
  if [[ -z "$file" ]]; then
    __pmux_ask "Which file?"
    read file
  fi

  if [[ -f "$file" ]]; then
    command cat "$file"
  elif [[ -d "$file" ]]; then
    __pmux_info "That's a directory. Showing files instead:"
    __pmux_showfiles "$file"
  else
    __pmux_error "File not found: ${PMUX_DIM}$file${PMUX_RESET}"
    return 1
  fi
}

__pmux_newfolder() {
  local name="$1"
  if [[ -z "$name" ]]; then
    __pmux_ask "Folder name?"
    read name
  fi

  command mkdir -p "$name"
  __pmux_success "Created folder ${PMUX_CYAN}$name${PMUX_RESET}"
}

__pmux_newfile() {
  local name="$1"
  if [[ -z "$name" ]]; then
    __pmux_ask "File name?"
    read name
  fi

  command touch "$name"
  __pmux_success "Created file ${PMUX_CYAN}$name${PMUX_RESET}"
}

__pmux_whereami() {
  __pmux_info "${PMUX_CYAN}$PWD${PMUX_RESET}"
}
