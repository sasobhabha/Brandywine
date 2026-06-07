#!/bin/sh
# DXVK-macOS launcher (POSIX sh)
# Exports WINEDLLPATH pointing to Contents/Resources/dxvk-macos
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)
DXVK_DIR="$SCRIPT_DIR/../Resources/dxvk-macos"

export WINEDLLPATH="$DXVK_DIR"

WINEPREFIX=${WINEPREFIX:-"$HOME/Library/Application Support/Brandywine/Prefix"}
export WINEPREFIX

LOG_DIR="$HOME/Library/Logs/Brandywine"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/dxvk-macos-launcher.log"

if [ -n "${BRANDYWINE_WINE_PATH:-}" ]; then
  WINE_BIN="$BRANDYWINE_WINE_PATH"
elif [ -x "${PWD}/BrandyCmd" ]; then
  WINE_BIN="${PWD}/BrandyCmd"
else
  WINE_BIN="wine"
fi

echo "DXVK-macOS launcher starting. DXVK_DIR=$DXVK_DIR" >> "$LOG_FILE"
echo "WINEDLLPATH=$WINEDLLPATH" >> "$LOG_FILE"
echo "WINEPREFIX=$WINEPREFIX" >> "$LOG_FILE"
echo "Invoking Wine: $WINE_BIN $*" >> "$LOG_FILE"

if "$WINE_BIN" "$@" >> "$LOG_FILE" 2>&1; then
  exit 0
else
  RET=$?
  echo "Wine exited with code $RET" >> "$LOG_FILE"
  if grep -Eiq "dxvk|failed to load|d3d|vulkan|DXVK|cannot open shared object file" "$LOG_FILE"; then
    echo "[DXVK] Potential DXVK load failures detected. See $LOG_FILE for details." >&2
  fi
  exit $RET
fi
