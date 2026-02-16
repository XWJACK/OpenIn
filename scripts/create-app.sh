#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APPS_DIR="$PROJECT_DIR/Apps"

usage() {
    echo "Usage: $0 --name <AppDirName> --app <TargetAppName> --type <editor|terminal> --bundle-id <BundleID>"
    echo ""
    echo "Example:"
    echo "  $0 --name OpenInSublime --app 'Sublime Text' --type editor --bundle-id com.xwjack.OpenInSublime"
}

NAME=""
APP=""
TYPE=""
BUNDLE_ID=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)     NAME="$2";      shift 2 ;;
        --app)      APP="$2";       shift 2 ;;
        --type)     TYPE="$2";      shift 2 ;;
        --bundle-id) BUNDLE_ID="$2"; shift 2 ;;
        *)          usage; exit 1 ;;
    esac
done

if [ -z "$NAME" ] || [ -z "$APP" ] || [ -z "$TYPE" ] || [ -z "$BUNDLE_ID" ]; then
    usage
    exit 1
fi

if [ "$TYPE" != "editor" ] && [ "$TYPE" != "terminal" ]; then
    echo "Error: --type must be 'editor' or 'terminal'"
    exit 1
fi

APP_DIR="$APPS_DIR/$NAME"
if [ -d "$APP_DIR" ]; then
    echo "Error: $APP_DIR already exists"
    exit 1
fi

mkdir -p "$APP_DIR"

cat > "$APP_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${NAME}</string>
    <key>CFBundleExecutable</key>
    <string>${NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>OITAppName</key>
    <string>${APP}</string>
    <key>OITAppType</key>
    <string>${TYPE}</string>
</dict>
</plist>
EOF

echo "Created $APP_DIR/"
echo "  Info.plist configured for '$APP' ($TYPE)"
echo ""
echo "Next steps:"
echo "  1. Add AppIcon.icns to $APP_DIR/"
echo "  2. Run: ./scripts/build.sh $NAME"
