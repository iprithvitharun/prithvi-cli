#!/usr/bin/env zsh
# ╔══════════════════════════════════════════════════════╗
# ║  pmux.sh — A human-friendly shell for Ghostty       ║
# ╚══════════════════════════════════════════════════════╝

PMUX_DIR="${0:A:h}"

# ── Source all modules ──────────────────────────────────
source "$PMUX_DIR/lib/colors.zsh"
source "$PMUX_DIR/lib/banner.zsh"
source "$PMUX_DIR/lib/picker.zsh"
source "$PMUX_DIR/lib/prompt.zsh"
source "$PMUX_DIR/commands/filesystem.zsh"
source "$PMUX_DIR/commands/git.zsh"
source "$PMUX_DIR/commands/tabs.zsh"
source "$PMUX_DIR/commands/npm.zsh"
source "$PMUX_DIR/commands/claude.zsh"

# ── Command interception via accept-line widget ─────────
# Overrides the Enter key handler. If the typed command matches
# a custom command, we run it directly (in the current shell)
# and reset the buffer. Otherwise, we let zsh execute normally.
__pmux_run() {
  # Save to history, clear buffer, show new prompt, then run handler
  print -s -- "$BUFFER"
  BUFFER=""
  zle accept-line
  "$@"
}

__pmux_accept_line() {
  local cmd="${BUFFER:l}"   # lowercase for matching
  local raw="$BUFFER"       # original case for arguments

  # Helper: extract argument after N characters from original input
  local arg

  case "$cmd" in
    "go to "*)     arg="${raw:6}";  __pmux_run __pmux_goto "$arg" ;;
    "go back")     __pmux_run __pmux_goback ;;
    "go home")     __pmux_run __pmux_gohome ;;
    "show files"*) arg="${raw:10}"; __pmux_run __pmux_showfiles "$arg" ;;
    "open "*)      arg="${raw:5}";  __pmux_run __pmux_open "$arg" ;;
    "new folder "*)arg="${raw:11}"; __pmux_run __pmux_newfolder "$arg" ;;
    "new file "*)  arg="${raw:9}";  __pmux_run __pmux_newfile "$arg" ;;
    "where am i")  __pmux_run __pmux_whereami ;;

    "git status")     __pmux_run __pmux_git_status ;;
    "git save")       __pmux_run __pmux_git_save ;;
    "git push")       __pmux_run __pmux_git_push ;;
    "git pull")       __pmux_run __pmux_git_pull ;;
    "git branch")     __pmux_run __pmux_git_branch ;;
    "git switch")     __pmux_run __pmux_git_switch ;;
    "git new branch") __pmux_run __pmux_git_new_branch ;;
    "git log")        __pmux_run __pmux_git_log ;;
    "git undo")       __pmux_run __pmux_git_undo ;;
    "git discard")    __pmux_run __pmux_git_discard ;;
    "git stash")      __pmux_run __pmux_git_stash ;;
    "git unstash")    __pmux_run __pmux_git_unstash ;;
    "git diff")       __pmux_run __pmux_git_diff ;;

    "tab new"*)    arg="${raw:7}";  __pmux_run __pmux_tab_new "$arg" ;;
    "tab split"*)  arg="${raw:9}";  __pmux_run __pmux_tab_split "$arg" ;;
    "tab rename "*)arg="${raw:11}"; __pmux_run __pmux_tab_rename "$arg" ;;
    "tab list")    __pmux_run __pmux_tab_list ;;
    "tab close")   __pmux_run __pmux_tab_close ;;

    "npm start")   __pmux_run __pmux_npm_start ;;
    "npm dev")     __pmux_run __pmux_npm_dev ;;
    "npm build")   __pmux_run __pmux_npm_build ;;
    "npm test")    __pmux_run __pmux_npm_test ;;
    "npm install"*)arg="${raw:11}"; __pmux_run __pmux_npm_install "$arg" ;;
    "npm remove "*)arg="${raw:11}"; __pmux_run __pmux_npm_remove "$arg" ;;
    "npm run "*)   arg="${raw:8}";  __pmux_run __pmux_npm_run "$arg" ;;

    "claude"*)     arg="${raw:6}";  __pmux_run __pmux_claude "$arg" ;;

    "help"|"commands") __pmux_run __pmux_help ;;

    *)
      # Not a custom command — let zsh handle it normally
      zle .accept-line
      ;;
  esac
}

zle -N accept-line __pmux_accept_line

# ── Help system ─────────────────────────────────────────
__pmux_help() {
  print ""
  print "${PMUX_BOLD}${PMUX_CYAN}  pmux.sh${PMUX_RESET} — Human-friendly commands for your terminal"
  print ""
  print "  ${PMUX_DIM}────────────────────────────────────────────${PMUX_RESET}"
  print ""
  print "  ${PMUX_BOLD}Filesystem${PMUX_RESET}"
  print "  ${PMUX_PINK}go to${PMUX_RESET} <folder>        cd into a directory"
  print "  ${PMUX_PINK}go back${PMUX_RESET}               cd .."
  print "  ${PMUX_PINK}go home${PMUX_RESET}               cd ~"
  print "  ${PMUX_PINK}show files${PMUX_RESET} [path]     ls (with optional path)"
  print "  ${PMUX_PINK}open${PMUX_RESET} <file>           cat a file"
  print "  ${PMUX_PINK}new folder${PMUX_RESET} <name>     mkdir"
  print "  ${PMUX_PINK}new file${PMUX_RESET} <name>       touch"
  print "  ${PMUX_PINK}where am i${PMUX_RESET}            pwd"
  print ""
  print "  ${PMUX_BOLD}Git${PMUX_RESET}"
  print "  ${PMUX_PINK}git status${PMUX_RESET}            working tree status"
  print "  ${PMUX_PINK}git save${PMUX_RESET}              stage all + commit (asks message)"
  print "  ${PMUX_PINK}git push${PMUX_RESET}              push to remote"
  print "  ${PMUX_PINK}git pull${PMUX_RESET}              pull from remote"
  print "  ${PMUX_PINK}git branch${PMUX_RESET}            list branches"
  print "  ${PMUX_PINK}git switch${PMUX_RESET}            switch branch (asks which)"
  print "  ${PMUX_PINK}git new branch${PMUX_RESET}        create + switch (asks name)"
  print "  ${PMUX_PINK}git log${PMUX_RESET}               pretty commit history"
  print "  ${PMUX_PINK}git undo${PMUX_RESET}              undo last commit (asks confirm)"
  print "  ${PMUX_PINK}git discard${PMUX_RESET}           discard all changes (asks confirm)"
  print "  ${PMUX_PINK}git stash${PMUX_RESET}             stash changes"
  print "  ${PMUX_PINK}git unstash${PMUX_RESET}           restore stashed changes"
  print "  ${PMUX_PINK}git diff${PMUX_RESET}              show unstaged changes"
  print ""
  print "  ${PMUX_BOLD}Tabs${PMUX_RESET}"
  print "  ${PMUX_PINK}tab new${PMUX_RESET} [name]        open a new tab"
  print "  ${PMUX_PINK}tab split${PMUX_RESET} [dir]       split pane (right/down)"
  print "  ${PMUX_PINK}tab rename${PMUX_RESET} <name>     rename current tab"
  print "  ${PMUX_PINK}tab close${PMUX_RESET}             close current tab"
  print ""
  print "  ${PMUX_BOLD}npm${PMUX_RESET}"
  print "  ${PMUX_PINK}npm dev${PMUX_RESET}               npm run dev"
  print "  ${PMUX_PINK}npm build${PMUX_RESET}             npm run build"
  print "  ${PMUX_PINK}npm install${PMUX_RESET} [pkg]     install packages"
  print "  ${PMUX_PINK}npm remove${PMUX_RESET} <pkg>      uninstall a package"
  print ""
  print "  ${PMUX_BOLD}Claude${PMUX_RESET}"
  print "  ${PMUX_PINK}claude${PMUX_RESET}                launch Claude Code"
  print "  ${PMUX_PINK}claude${PMUX_RESET} <prompt>       ask Claude a question"
  print ""
  print "  ${PMUX_DIM}All native commands (cd, ls, git, etc.) still work normally.${PMUX_RESET}"
  print ""
}

# ── Welcome banner ────────────────────────────────────────────
__pmux_banner
