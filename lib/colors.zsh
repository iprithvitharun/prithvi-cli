#!/usr/bin/env zsh
# Color and formatting constants
# Using $'...' syntax so \033 is interpreted as a real escape character.

PMUX_RESET=$'\033[0m'
PMUX_BOLD=$'\033[1m'
PMUX_DIM=$'\033[2m'
PMUX_ITALIC=$'\033[3m'

# Colors
PMUX_RED=$'\033[38;5;203m'
PMUX_GREEN=$'\033[38;5;114m'
PMUX_YELLOW=$'\033[38;5;221m'
PMUX_BLUE=$'\033[38;5;111m'
PMUX_PINK=$'\033[38;5;210m'
PMUX_CYAN=$'\033[38;5;117m'
PMUX_GRAY=$'\033[38;5;243m'
PMUX_WHITE=$'\033[38;5;255m'

# Utility print functions
__pmux_success() { print "  ${PMUX_GREEN}✓${PMUX_RESET} $1" }
__pmux_error()   { print "  ${PMUX_RED}✗${PMUX_RESET} $1" }
__pmux_info()    { print "  ${PMUX_BLUE}→${PMUX_RESET} $1" }
__pmux_warn()    { print "  ${PMUX_YELLOW}!${PMUX_RESET} $1" }
__pmux_ask()     { print -n "  ${PMUX_PINK}?${PMUX_RESET} $1 " }
