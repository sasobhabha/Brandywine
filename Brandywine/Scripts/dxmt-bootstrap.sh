#!/bin/sh
# DXMT prefix bootstrap (POSIX sh)
# Creates WINEPREFIX if missing.
# DXMT DLLs are installed as Wine builtins, so no DLL overrides are needed.
set -eu

# Default WINEPREFIX if not provided
WINEPREFIX=${WINEPREFIX:-"$HOME/Library/Application Support/Brandywine/Prefix"}
export WINEPREFIX

echo "Using WINEPREFIX: $WINEPREFIX"

# Ensure prefix directory exists
if [ ! -d "$WINEPREFIX" ]; then
  echo "Creating WINEPREFIX directory: $WINEPREFIX"
  mkdir -p "$WINEPREFIX"
  # Initialize prefix (wineboot may fail if wine isn't installed; ignore error)
  if command -v wine >/dev/null 2>&1; then
    echo "Initializing Wine prefix with wineboot"
    wineboot -u >/dev/null 2>&1 || true
  else
    echo "wine not found in PATH; prefix directory created but not initialized"
  fi
fi

echo "DXMT prefix bootstrap complete."
exit 0
