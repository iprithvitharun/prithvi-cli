#!/usr/bin/env zsh
# Ghostty tab management
#
# Ghostty supports controlling the terminal via:
# 1. OSC sequences for tab titles
# 2. Ghostty's built-in keybinding actions via `ghostty` CLI (if available)
# 3. AppleScript for macOS window/tab management

# ── Set tab title via OSC escape sequence ───────────────
__pmux_set_tab_title() {
  local title="$1"
  # OSC 0 sets both window and tab title
  print -n "\033]0;${title}\007"
}

# ── Tab: new ────────────────────────────────────────────
__pmux_tab_new() {
  local name="${1// /}"

  if command -v ghostty &>/dev/null; then
    # Use Ghostty CLI if available
    ghostty +new-tab 2>/dev/null
  else
    # Use AppleScript to create a new tab in Ghostty
    osascript -e '
      tell application "Ghostty"
        activate
        tell application "System Events"
          keystroke "t" using command down
        end tell
      end tell
    ' 2>/dev/null
  fi

  # Auto-increment tab counter
  : ${__pmux_tab_counter:=0}
  (( __pmux_tab_counter++ ))

  if [[ -z "$name" ]]; then
    name="Untitled Term $__pmux_tab_counter"
  fi

  # Small delay to let the new tab open
  sleep 0.3
  __pmux_set_tab_title "$name"
  __pmux_success "New tab: ${PMUX_CYAN}$name${PMUX_RESET}"
}

# ── Tab: split ──────────────────────────────────────────
__pmux_tab_split() {
  local direction="${1// /}"
  direction="${direction:-right}"

  case "$direction" in
    right|r)
      if command -v ghostty &>/dev/null; then
        ghostty +new-split --direction=right 2>/dev/null
      else
        osascript -e '
          tell application "Ghostty"
            activate
            tell application "System Events"
              keystroke "d" using command down
            end tell
          end tell
        ' 2>/dev/null
      fi
      __pmux_success "Split pane → right"
      ;;
    down|d)
      if command -v ghostty &>/dev/null; then
        ghostty +new-split --direction=down 2>/dev/null
      else
        osascript -e '
          tell application "Ghostty"
            activate
            tell application "System Events"
              keystroke "d" using {command down, shift down}
            end tell
          end tell
        ' 2>/dev/null
      fi
      __pmux_success "Split pane ↓ down"
      ;;
    *)
      __pmux_error "Direction must be ${PMUX_PINK}right${PMUX_RESET} or ${PMUX_PINK}down${PMUX_RESET}"
      return 1
      ;;
  esac
}

# ── Tab: rename ─────────────────────────────────────────
__pmux_tab_rename() {
  local name="$1"
  if [[ -z "$name" ]]; then
    __pmux_ask "Tab name?"
    read name
  fi

  __pmux_set_tab_title "$name"
  __pmux_success "Tab renamed to ${PMUX_CYAN}$name${PMUX_RESET}"
}

# ── Tab: list ───────────────────────────────────────────
__pmux_tab_list() {
  __pmux_info "Open tabs in Ghostty:"
  osascript -e '
    tell application "Ghostty"
      tell application "System Events"
        tell process "Ghostty"
          set tabCount to count of radio buttons of tab group 1 of window 1
          repeat with i from 1 to tabCount
            set tabName to name of radio button i of tab group 1 of window 1
            log tabName
          end repeat
        end tell
      end tell
    end tell
  ' 2>&1 | while IFS= read -r line; do
    print "  ${PMUX_GRAY}○${PMUX_RESET} $line"
  done
}

# ── Tab: close ──────────────────────────────────────────
__pmux_tab_close() {
  osascript -e '
    tell application "Ghostty"
      activate
      tell application "System Events"
        keystroke "w" using command down
      end tell
    end tell
  ' 2>/dev/null
  __pmux_success "Tab closed"
}
