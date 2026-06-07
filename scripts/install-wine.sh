#!/usr/bin/env bash
set -euo pipefail

BUNDLE_ID="${WINE_SASKER_BUNDLE_ID:-com.sasobha.brandywine}"
APP_SUPPORT="$HOME/Library/Application Support/$BUNDLE_ID/Libraries"
ARCHIVE="${1:-$HOME/Downloads/wine-staging-11.9-osx64.tar.xz}"

if [[ ! -f "$ARCHIVE" ]]; then
  echo "Wine archive not found: $ARCHIVE" >&2
  echo "Download: https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.9/wine-staging-11.9-osx64.tar.xz" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Extracting $ARCHIVE ..."
tar -xJf "$ARCHIVE" -C "$TMP"

WINE_SRC="$(find "$TMP" -path '*/Contents/Resources/wine' -type d | head -1)"
if [[ -z "$WINE_SRC" ]]; then
  echo "Could not find Wine resources in archive." >&2
  exit 1
fi

mkdir -p "$APP_SUPPORT"
if [[ -d "$APP_SUPPORT/Wine" ]]; then
  /bin/rm -rf "$APP_SUPPORT/Wine"
fi
cp -R "$WINE_SRC" "$APP_SUPPORT/Wine"

BIN="$APP_SUPPORT/Wine/bin"
if [[ -x "$BIN/wine" && ! -e "$BIN/wine64" ]]; then
  ln -sf wine "$BIN/wine64"
fi

cat > "$APP_SUPPORT/WhiskyWineVersion.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>version</key>
	<string>11.9.0</string>
</dict>
</plist>
EOF

echo "Installed Wine 11.9 to $APP_SUPPORT/Wine"
ls -la "$BIN/wine" "$BIN/wine64" 2>/dev/null || ls -la "$BIN/wine"
