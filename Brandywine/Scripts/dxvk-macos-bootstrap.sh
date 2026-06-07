#!/bin/sh
# DXVK-macOS prefix bootstrap (POSIX sh)
# Creates WINEPREFIX if missing.
# DXVK-macOS DLLs are installed via WINEDLLPATH, so no DLL overrides are needed.
set -eu

WINEPREFIX=${WINEPREFIX:-"$HOME/Library/Application Support/Brandywine/Prefix"}
export WINEPREFIX

echo "Using WINEPREFIX: $WINEPREFIX"

if [ ! -d "$WINEPREFIX" ]; then
  echo "Creating WINEPREFIX directory: $WINEPREFIX"
  mkdir -p "$WINEPREFIX"
  if command -v wine >/dev/null 2>&1; then
    echo "Initializing Wine prefix with wineboot"
    wineboot -u >/dev/null 2>&1 || true
  else
    echo "wine not found in PATH; prefix directory created but not initialized"
  fi
fi

echo "DXVK-macOS prefix bootstrap complete."
exit 0
