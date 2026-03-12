#!/usr/bin/env bash
# pmux.sh Installer
set -e

PMUX_DIR="$(cd "$(dirname "$0")" && pwd)"
SHELL_RC="$HOME/.zshrc"

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║      pmux.sh — Installer             ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# Check if already installed
if grep -q "prithvi-cli/pmux.zsh" "$SHELL_RC" 2>/dev/null; then
  echo "  ✓ pmux.sh is already in your .zshrc"
  echo "  → To reinstall, remove the line from $SHELL_RC and run again"
  echo ""
  exit 0
fi

# Add source line to .zshrc
echo "" >> "$SHELL_RC"
echo "# pmux.sh" >> "$SHELL_RC"
echo "source \"$PMUX_DIR/pmux.zsh\"" >> "$SHELL_RC"

echo "  ✓ Added to $SHELL_RC"
echo ""

# Check for Ghostty config
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
if [[ -f "$GHOSTTY_CONFIG" ]]; then
  echo "  → Ghostty config found at $GHOSTTY_CONFIG"
  echo "  → You can customize tab behavior in your Ghostty config."
  echo "  → See ghostty.example.conf for recommended settings."
else
  echo "  ! Ghostty config not found at $GHOSTTY_CONFIG"
  echo "  → If you use Ghostty, create the config and see ghostty.example.conf"
fi

echo ""
echo "  ✓ Installation complete!"
echo "  → Restart your terminal or run: source ~/.zshrc"
echo ""
