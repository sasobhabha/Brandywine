#!/bin/bash
export WINEPREFIX="$HOME/.gptk_bottle"
WINE_DIR="/Applications/Wine Stable.app/Contents/Resources/wine"
export WINE_BIN="$WINE_DIR/bin/wine"
export WINESERVER="$WINE_DIR/bin/wineserver"
export WINEMSYNC=1
export WINEESYNC=1

if [ ! -d "$WINEPREFIX" ]; then
    echo "Creating bottle..."
    "$WINE_BIN" wineboot -u
fi

EXE_PATH="$1"
shift
"$WINE_BIN" "$EXE_PATH" "$@"
