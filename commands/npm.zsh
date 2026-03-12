#!/usr/bin/env zsh
# npm command wrappers

__pmux_npm_start() {
  __pmux_info "Running ${PMUX_PINK}npm start${PMUX_RESET}..."
  command npm start
}

__pmux_npm_dev() {
  __pmux_info "Running ${PMUX_PINK}npm run dev${PMUX_RESET}..."
  command npm run dev
}

__pmux_npm_build() {
  __pmux_info "Running ${PMUX_PINK}npm run build${PMUX_RESET}..."
  command npm run build
}

__pmux_npm_test() {
  __pmux_info "Running ${PMUX_PINK}npm test${PMUX_RESET}..."
  command npm test
}

__pmux_npm_install() {
  local pkg="${1// /}"
  if [[ -n "$pkg" ]]; then
    __pmux_info "Installing ${PMUX_CYAN}$pkg${PMUX_RESET}..."
    command npm install "$pkg"
    if [[ $? -eq 0 ]]; then
      __pmux_success "Installed ${PMUX_CYAN}$pkg${PMUX_RESET}"
    else
      __pmux_error "Failed to install $pkg"
    fi
  else
    __pmux_info "Installing dependencies..."
    command npm install
    if [[ $? -eq 0 ]]; then
      __pmux_success "All dependencies installed"
    else
      __pmux_error "Install failed"
    fi
  fi
}

__pmux_npm_remove() {
  local pkg="$1"
  if [[ -z "$pkg" ]]; then
    __pmux_ask "Which package?"
    read pkg
  fi

  __pmux_info "Removing ${PMUX_CYAN}$pkg${PMUX_RESET}..."
  command npm uninstall "$pkg"
  if [[ $? -eq 0 ]]; then
    __pmux_success "Removed ${PMUX_CYAN}$pkg${PMUX_RESET}"
  else
    __pmux_error "Failed to remove $pkg"
  fi
}

__pmux_npm_run() {
  local script="$1"
  if [[ -z "$script" ]]; then
    __pmux_ask "Which script?"
    read script
  fi

  __pmux_info "Running ${PMUX_PINK}npm run $script${PMUX_RESET}..."
  command npm run "$script"
}
