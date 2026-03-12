#!/usr/bin/env zsh
# Interactive arrow-key picker for pmux.sh

# Usage: __pmux_picker item1 item2 item3 ...
# Returns: selected item via stdout, empty if cancelled
# All UI rendering goes to /dev/tty so it works inside $()
__pmux_picker() {
  local -a items=("$@")
  local count=${#items}
  local selected=1
  local key

  (( count == 0 )) && return 1

  # Colors
  local hi=$'\033[38;5;210m\033[1m'  # pink bold (selected)
  local dir_c=$'\033[38;5;117m'       # cyan (directories)
  local file_c=$'\033[38;5;243m'      # gray (files)
  local dim=$'\033[2m'                # dim
  local r=$'\033[0m'                  # reset
  local clr=$'\033[2K'                # clear line

  # Render the list to /dev/tty
  __pmux_picker_render() {
    local i
    for (( i = 1; i <= count; i++ )); do
      local item="${items[$i]}"
      local suffix=""
      [[ -d "$item" ]] && suffix="/"

      if (( i == selected )); then
        print "\r${clr}  ${hi}❯ ${item}${suffix}${r}" > /dev/tty
      elif [[ -d "$item" ]]; then
        print "\r${clr}    ${dir_c}${item}${suffix}${r}" > /dev/tty
      else
        print "\r${clr}    ${file_c}${item}${r}" > /dev/tty
      fi
    done
  }

  # Initial render
  print "" > /dev/tty
  __pmux_picker_render

  # Hint line
  print "\r${clr}  ${dim}↑↓ navigate  ↵ select  esc cancel${r}" > /dev/tty

  local total_lines=$(( count + 1 ))

  # Input loop — read from /dev/tty
  while true; do
    read -r -s -k 1 key < /dev/tty

    if [[ "$key" == $'\e' ]]; then
      read -r -s -k 1 -t 0.1 key < /dev/tty 2>/dev/null
      if [[ "$key" == "[" ]]; then
        read -r -s -k 1 -t 0.1 key < /dev/tty 2>/dev/null
        case "$key" in
          A) # Up
            (( selected > 1 )) && (( selected-- ))
            ;;
          B) # Down
            (( selected < count )) && (( selected++ ))
            ;;
        esac
      else
        # Plain Escape — cancel
        print "" > /dev/tty
        return 1
      fi
    elif [[ "$key" == $'\n' || "$key" == $'\r' ]]; then
      # Enter — confirm
      print "" > /dev/tty
      print -r -- "${items[$selected]}"
      return 0
    elif [[ "$key" == "q" ]]; then
      print "" > /dev/tty
      return 1
    else
      continue
    fi

    # Redraw: move cursor up and overwrite
    printf '\033[%dA' "$total_lines" > /dev/tty
    __pmux_picker_render
    print "\r${clr}  ${dim}↑↓ navigate  ↵ select  esc cancel${r}" > /dev/tty
  done
}
