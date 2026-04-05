#!/bin/sh
# DXVK prefix bootstrap (POSIX sh)
# Creates WINEPREFIX if missing and adds idempotent DLL overrides
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

# Helper: set a DLL override in the Wine registry idempotently
set_override() {
  NAME="$1"
  VAL="$2"

  if ! command -v wine >/dev/null 2>&1; then
    echo "wine not found; cannot set registry override for $NAME"
    return 0
  fi

  # Query existing value (succeeds if present)
  if wine reg query "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v "$NAME" >/dev/null 2>&1; then
    # Read current value
    CUR_VAL=$(wine reg query "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v "$NAME" 2>/dev/null | awk -F"REG_SZ" '{print $2}' | sed -e 's/^\s*//')
    if [ "$CUR_VAL" = "$VAL" ]; then
      echo "Override for $NAME already set to $VAL"
      return 0
    fi
  fi

  echo "Setting override: $NAME = $VAL"
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v "$NAME" /t REG_SZ /d "$VAL" /f >/dev/null 2>&1 || true
}

# Desired overrides
set_override "d3d11" "native,builtin"
set_override "dxgi" "native,builtin"
set_override "d3d10core" "native,builtin"
set_override "d3d9" "native,builtin"

echo "DXVK prefix bootstrap complete."
exit 0
