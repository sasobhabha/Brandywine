#!/bin/sh
# DXMT launcher (POSIX sh)
# Exports WINEDLLPATH and DYLD_FALLBACK_LIBRARY_PATH pointing to Contents/Resources/dxmt
set -eu

# Determine executable dir (this script will be copied into Contents/MacOS)
SCRIPT_DIR=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)
# DXMT dir inside the .app bundle
DXMT_DIR="$SCRIPT_DIR/../Resources/dxmt"

export WINEDLLPATH="$DXMT_DIR"
# Prepend to DYLD_FALLBACK_LIBRARY_PATH if set, else set new
if [ -n "${DYLD_FALLBACK_LIBRARY_PATH:-}" ]; then
  export DYLD_FALLBACK_LIBRARY_PATH="$DXMT_DIR:$DYLD_FALLBACK_LIBRARY_PATH"
else
  export DYLD_FALLBACK_LIBRARY_PATH="$DXMT_DIR"
fi

# Default WINEPREFIX if not provided
WINEPREFIX=${WINEPREFIX:-"$HOME/Library/Application Support/Brandywine/Prefix"}
export WINEPREFIX

# Log file for DXMT diagnostics
LOG_DIR="$HOME/Library/Logs/Brandywine"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/dxmt-launcher.log"

# Choose wine binary
if [ -n "${BRANDYWINE_WINE_PATH:-}" ]; then
  WINE_BIN="$BRANDYWINE_WINE_PATH"
elif [ -x "${PWD}/BrandyCmd" ]; then
  WINE_BIN="${PWD}/BrandyCmd"
else
  WINE_BIN="wine"
fi

echo "DXMT launcher starting. DXMT_DIR=$DXMT_DIR" >> "$LOG_FILE"

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
  if grep -Eiq "dxmt|dxvk|failed to load|d3d|vulkan|DXVK|cannot open shared object file" "$LOG_FILE"; then
    echo "[DXMT] Potential DXMT/DXVK load failures detected. See $LOG_FILE for details." >&2
  fi
  exit $RET
fi
