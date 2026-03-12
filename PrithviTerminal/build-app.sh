#!/bin/bash
# Build pmux.sh as a macOS .app bundle
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/.build/release"
APP_DIR="$SCRIPT_DIR/build/pmux.sh.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo ""
echo "  Building pmux.sh..."
echo ""

# Build release binary
cd "$SCRIPT_DIR"
swift build -c release 2>&1

echo ""
echo "  Creating app bundle..."
echo ""

# Create .app structure
rm -rf "$APP_DIR"
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy binary
cp "$BUILD_DIR/PmuxTerminal" "$MACOS/PmuxTerminal"

# Copy Info.plist
cp "$SCRIPT_DIR/PrithviTerminal/Info.plist" "$CONTENTS/Info.plist"

# Create PkgInfo
echo -n "APPL????" > "$CONTENTS/PkgInfo"

# Copy app icon
cp "$SCRIPT_DIR/PrithviTerminal/AppIcon.icns" "$RESOURCES/AppIcon.icns"

echo ""
echo "  ✓ Built: $APP_DIR"
echo ""
echo "  To run:"
echo "    open \"$APP_DIR\""
echo ""
echo "  To install to /Applications:"
echo "    cp -R \"$APP_DIR\" /Applications/"
echo ""
