#!/bin/sh
# DXVK launcher (POSIX sh)
# Exports WINEDLLPATH and DYLD_FALLBACK_LIBRARY_PATH pointing to Contents/Resources/dxvk-macos
# Launches wine with provided arguments and logs DXVK load failures
set -eu

# Determine executable dir (this script will be copied into Contents/MacOS)
SCRIPT_DIR=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)
# DXVK dir inside the .app bundle
DXVK_DIR="$SCRIPT_DIR/../Resources/dxvk-macos"

export WINEDLLPATH="$DXVK_DIR"
# Prepend to DYLD_FALLBACK_LIBRARY_PATH if set, else set new
if [ -n "${DYLD_FALLBACK_LIBRARY_PATH:-}" ]; then
  export DYLD_FALLBACK_LIBRARY_PATH="$DXVK_DIR:$DYLD_FALLBACK_LIBRARY_PATH"
else
  export DYLD_FALLBACK_LIBRARY_PATH="$DXVK_DIR"
fi

# Default WINEPREFIX if not provided
WINEPREFIX=${WINEPREFIX:-"$HOME/Library/Application Support/Brandywine/Prefix"}
export WINEPREFIX

# Log file for DXVK diagnostics
LOG_DIR="$HOME/Library/Logs/Brandywine"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/dxvk-launcher.log"

# Choose wine binary
if [ -n "${BRANDYWINE_WINE_PATH:-}" ]; then
  WINE_BIN="$BRANDYWINE_WINE_PATH"
elif [ -x "${PWD}/BrandyCmd" ]; then
  WINE_BIN="${PWD}/BrandyCmd"
else
  WINE_BIN="wine"
fi

echo "DXVK launcher starting. DXVK_DIR=$DXVK_DIR" >> "$LOG_FILE"

echo "WINEDLLPATH=$WINEDLLPATH" >> "$LOG_FILE"
echo "DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH" >> "$LOG_FILE"
echo "WINEPREFIX=$WINEPREFIX" >> "$LOG_FILE"

echo "Invoking Wine: $WINE_BIN $*" >> "$LOG_FILE"

# Run wine and capture output
# shellcheck disable=SC2086
if "$WINE_BIN" "$@" >> "$LOG_FILE" 2>&1; then
  exit 0
else
  RET=$?
  echo "Wine exited with code $RET" >> "$LOG_FILE"
  # Check for common DXVK failure indicators in log and print summary
  if grep -Eiq "dxvk|failed to load|d3d|vulkan|DXVK|cannot open shared object file" "$LOG_FILE"; then
    echo "[DXVK] Potential DXVK load failures detected. See $LOG_FILE for details." >&2
  fi
  exit $RET
fi
