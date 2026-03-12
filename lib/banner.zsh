#!/usr/bin/env zsh
# pmux.sh — Startup banners

# ── System info helpers ──────────────────────────────────────
__pmux_greeting() {
  local hour=$(date +%H)
  if   (( hour >= 5  && hour < 12 )); then print -n "Good morning"
  elif (( hour >= 12 && hour < 17 )); then print -n "Good afternoon"
  elif (( hour >= 17 && hour < 21 )); then print -n "Good evening"
  else                                     print -n "Good night"
  fi
}

__pmux_uptime_short() {
  local raw=$(uptime 2>/dev/null)
  # Match "up X days, H:MM" or "up H:MM" or "up X days"
  if [[ "$raw" =~ "up ([0-9]+) days?,[ ]*([0-9]+):([0-9]+)" ]]; then
    print -n "${match[1]}d ${match[2]}h"
  elif [[ "$raw" =~ "up ([0-9]+):([0-9]+)" ]]; then
    if (( match[1] > 0 )); then
      print -n "${match[1]}h ${match[2]}m"
    else
      print -n "${match[2]}m"
    fi
  elif [[ "$raw" =~ "up ([0-9]+) days?" ]]; then
    print -n "${match[1]}d"
  elif [[ "$raw" =~ "up ([0-9]+) mins?" ]]; then
    print -n "${match[1]}m"
  else
    print -n "—"
  fi
}

__pmux_memory_short() {
  local mem_total
  mem_total=$(sysctl -n hw.memsize 2>/dev/null)
  if [[ -n "$mem_total" ]]; then
    local total_gb=$(( mem_total / 1073741824 ))
    # Use vm_stat for used memory
    local page_size=$(pagesize 2>/dev/null || sysctl -n hw.pagesize 2>/dev/null)
    local vm=$(vm_stat 2>/dev/null)
    local active=$(echo "$vm" | awk '/Pages active/ {gsub(/\./,"",$3); print $3}')
    local wired=$(echo "$vm" | awk '/Pages wired/ {gsub(/\./,"",$4); print $4}')
    local compressed=$(echo "$vm" | awk '/Pages occupied by compressor/ {gsub(/\./,"",$5); print $5}')
    if [[ -n "$active" && -n "$wired" && -n "$page_size" ]]; then
      local used_pages=$(( active + wired + ${compressed:-0} ))
      local used_gb=$(( (used_pages * page_size) / 1073741824 ))
      local used_frac=$(( ((used_pages * page_size) % 1073741824) * 10 / 1073741824 ))
      print -n "${used_gb}.${used_frac}/${total_gb}GB"
    else
      print -n "${total_gb}GB"
    fi
  else
    print -n "—"
  fi
}

# ── Full gradient wave banner (startup / first tab) ──────────
__pmux_banner_full() {
  local c1=$'\033[38;5;117m'  # cyan
  local c2=$'\033[38;5;153m'  # light blue
  local c3=$'\033[38;5;183m'  # lavender
  local c4=$'\033[38;5;210m'  # pink
  local cy=$'\033[38;5;221m'  # yellow
  local d=$'\033[2m'          # dim
  local b=$'\033[1m'          # bold
  local r=$'\033[0m'          # reset

  local cg=$'\033[38;5;114m'  # green

  # Gather info
  local greeting=$(__pmux_greeting)
  local uptime=$(__pmux_uptime_short)
  local memory=$(__pmux_memory_short)
  local git_user=$(gh auth status 2>&1 | grep -B1 "Active account: true" | head -1 | grep -o 'account [^ ]*' | cut -d' ' -f2)

  print ""
  print "    ${c1}░░${c2}▒▒${c3}▓▓${b}${c4}████████████████████████${r}${c3}▓▓${c2}▒▒${c1}░░${r}"
  print "    ${c2}▒▒${c3}▓▓${c4}██${r}  ${b}${c1}p ${c2}m ${c3}u ${c4}x ${c1}. ${c2}s ${c3}h${r}  ${c4}██${c3}▓▓${c2}▒▒${r}"
  print "    ${c1}░░${c2}▒▒${c3}▓▓${b}${c4}████████████████████████${r}${c3}▓▓${c2}▒▒${c1}░░${r}"
  print ""
  print "    ${b}${c1}${greeting}${r}  ${d}pmux.sh v0.1.0${r}  ${c2}⏱${r} ${c3}${uptime}${r}  ${c2}⬡${r} ${cy}${memory}${r}${git_user:+  ${cg}⌘${r} ${cg}${git_user}${r}}"
  print ""
}

# ── Compact banner (new tabs) ────────────────────────────────
__pmux_banner_compact() {
  local c1=$'\033[38;5;117m'  # cyan
  local c2=$'\033[38;5;153m'  # light blue
  local c3=$'\033[38;5;183m'  # lavender
  local c4=$'\033[38;5;210m'  # pink
  local cy=$'\033[38;5;221m'  # yellow
  local cg=$'\033[38;5;114m'  # green
  local d=$'\033[2m'          # dim
  local b=$'\033[1m'          # bold
  local r=$'\033[0m'          # reset

  local uptime=$(__pmux_uptime_short)
  local memory=$(__pmux_memory_short)
  local git_user=$(gh auth status 2>&1 | grep -B1 "Active account: true" | head -1 | grep -o 'account [^ ]*' | cut -d' ' -f2)

  print ""
  print "    ${c1}▓${c3}▒${c4}░${r} ${b}${c1}pmux.sh${r}  ${c2}⏱${r} ${c3}${uptime}${r}  ${c2}⬡${r} ${cy}${memory}${r}${git_user:+  ${cg}⌘${r} ${cg}${git_user}${r}} ${c4}░${c3}▒${c1}▓${r}"
  print ""
}

# ── Show the right banner based on context ───────────────────
__pmux_banner() {
  if [[ "${PMUX_TAB_NUMBER:-1}" -gt 1 ]]; then
    __pmux_banner_compact
  else
    __pmux_banner_full
  fi
}
