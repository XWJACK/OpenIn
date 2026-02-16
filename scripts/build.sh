#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/release"
OUTPUT_DIR="$PROJECT_DIR/build"
APPS_DIR="$PROJECT_DIR/Apps"

# All available apps (directory names under Apps/)
ALL_APPS=()
for dir in "$APPS_DIR"/*/; do
    [ -d "$dir" ] && ALL_APPS+=("$(basename "$dir")")
done

usage() {
    echo "Usage: $0 [--all | AppName ...]"
    echo ""
    echo "Examples:"
    echo "  $0 OpenInCursor              # Build one app"
    echo "  $0 OpenInCursor OpenInVSCode  # Build multiple apps"
    echo "  $0 --all                      # Build all apps"
    echo ""
    echo "Available apps:"
    for app in "${ALL_APPS[@]}"; do
        echo "  $app"
    done
}

# Parse arguments
TARGETS=()
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

if [ "$1" = "--all" ]; then
    TARGETS=("${ALL_APPS[@]}")
else
    TARGETS=("$@")
fi

# Validate targets
for target in "${TARGETS[@]}"; do
    if [ ! -d "$APPS_DIR/$target" ]; then
        echo "Error: App '$target' not found in $APPS_DIR/"
        exit 1
    fi
    if [ ! -f "$APPS_DIR/$target/Info.plist" ]; then
        echo "Error: Info.plist not found for '$target'"
        exit 1
    fi
done

# Build once
echo "Building release binary..."
cd "$PROJECT_DIR"
swift build -c release
echo "Build complete."

# Create .app bundle for each target
mkdir -p "$OUTPUT_DIR"

for target in "${TARGETS[@]}"; do
    echo ""
    echo "Packaging $target.app..."

    APP_DIR="$OUTPUT_DIR/$target.app"
    CONTENTS_DIR="$APP_DIR/Contents"
    MACOS_DIR="$CONTENTS_DIR/MacOS"
    RESOURCES_DIR="$CONTENTS_DIR/Resources"

    rm -rf "$APP_DIR"
    mkdir -p "$MACOS_DIR"
    mkdir -p "$RESOURCES_DIR"

    # Copy binary (renamed to match CFBundleExecutable)
    cp "$BUILD_DIR/OpenIn" "$MACOS_DIR/$target"

    # Copy Info.plist
    cp "$APPS_DIR/$target/Info.plist" "$CONTENTS_DIR/"

    # Copy icon if exists
    if [ -f "$APPS_DIR/$target/AppIcon.icns" ]; then
        cp "$APPS_DIR/$target/AppIcon.icns" "$RESOURCES_DIR/"
    fi

    # Sign
    codesign --force --deep --sign - "$APP_DIR"

    echo "$target.app created at: $APP_DIR"
done

echo ""
echo "All done. Apps are in: $OUTPUT_DIR/"
