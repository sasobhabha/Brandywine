#!/usr/bin/env bash
# Optional: DXVK, winetricks, and verbs from Whisky's library bundle (Wine is installed separately via install-wine.sh).
set -euo pipefail

BUNDLE_ID="${WINE_SASKER_BUNDLE_ID:-com.sasobha.brandywine}"
APP_SUPPORT="$HOME/Library/Application Support/$BUNDLE_ID/Libraries"
URL="https://data.getwhisky.app/Wine/Libraries.tar.gz"
TMP="$(mktemp -d)"
ARCHIVE="$TMP/Libraries.tar.gz"

trap 'rm -rf "$TMP"' EXIT

echo "Downloading Whisky support libraries (DXVK, winetricks) ..."
curl -fL "$URL" -o "$ARCHIVE"
tar -xzf "$ARCHIVE" -C "$TMP"

SRC="$TMP/Libraries"
mkdir -p "$APP_SUPPORT"

for item in DXVK winetricks verbs.txt WhiskyWineVersion.plist; do
  if [[ -e "$SRC/$item" ]]; then
    /bin/rm -rf "$APP_SUPPORT/$item"
    cp -R "$SRC/$item" "$APP_SUPPORT/$item"
    echo "Installed $item"
  fi
done

# Keep our Gcenx Wine 11.9 version marker if already present
if [[ ! -f "$APP_SUPPORT/WhiskyWineVersion.plist" ]] && [[ -f "$SRC/WhiskyWineVersion.plist" ]]; then
  cp "$SRC/WhiskyWineVersion.plist" "$APP_SUPPORT/"
fi

echo "Extras installed under $APP_SUPPORT"
