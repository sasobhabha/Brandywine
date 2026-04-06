DXVK macOS integration

What was added
- Brandywine/Scripts/dxmt-bootstrap.sh: idempotent Wine prefix bootstrap. Creates WINEPREFIX (default: $HOME/Library/Application Support/Brandywine/Prefix) and sets DLL overrides for d3d11, dxgi, d3d10core, d3d9 to native,builtin.
- Brandywine/Scripts/dxmt-launcher.sh: runtime launcher that exports WINEDLLPATH and DYLD_FALLBACK_LIBRARY_PATH pointing to Contents/Resources/dxmt inside the .app bundle and launches Wine, logging DXMT load failures to ~/Library/Logs/Brandywine/dxmt-launcher.log.
- Xcode Run Script Build Phase added: "DXMT: Install launcher & set perms" — copies the launcher into the built .app at Contents/MacOS/Brandywine-dxmt and makes it executable.
- The folder Brandywine/Resources/dxmt is referenced in the project and will be copied into the app bundle Resources.

Manual usage
1. Bootstrap prefix (optional; requires wine on PATH):
   /bin/sh Brandywine/Scripts/dxmt-bootstrap.sh

2. Run Wine with the launcher (after building the app or copying the launcher into an .app bundle):
   /path/to/Brandywine.app/Contents/MacOS/Brandywine-dxmt <wine-arguments>

Notes
- Paths inside the app bundle use: Contents/Resources/dxmt
- This integration uses DXMT. vkd3d-proton and GPTK are intentionally excluded.
- The scripts are POSIX sh compatible.

DXMT upstream: https://github.com/3Shain/dxmt
