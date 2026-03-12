#!/usr/bin/env bash
# pmux.sh Uninstaller
set -e

SHELL_RC="$HOME/.zshrc"

echo ""
echo "  pmux.sh — Uninstaller"
echo ""

if grep -q "prithvi-cli/pmux.zsh" "$SHELL_RC" 2>/dev/null; then
  # Remove the source line and comment
  sed -i '' '/# pmux.sh/d' "$SHELL_RC"
  sed -i '' '/prithvi-cli\/pmux.zsh/d' "$SHELL_RC"
  echo "  ✓ Removed from $SHELL_RC"
  echo "  → Restart your terminal to complete uninstall"
else
  echo "  ! pmux.sh not found in $SHELL_RC"
fi

echo ""
