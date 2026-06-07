DXVK-macOS integration

What was added
- Brandywine/Scripts/dxvk-macos-bootstrap.sh: idempotent Wine prefix bootstrap. Creates WINEPREFIX (default: $HOME/Library/Application Support/Brandywine/Prefix).
- Brandywine/Scripts/dxvk-macos-launcher.sh: runtime launcher that exports WINEDLLPATH pointing to Contents/Resources/dxvk-macos inside the .app bundle and launches Wine, logging DXVK load failures to ~/Library/Logs/Brandywine/dxvk-macos-launcher.log.
- Xcode Run Script Build Phase added: "DXVK-macOS: Install DLLs" — copies DXVK-macOS DLLs into Contents/Resources/dxvk-macos/.
- Brandywine/Resources/dxvk-macos/ contains the DXVK-macOS v1.10.3-20230507 binaries:
  - x64/*.dll (64-bit Windows PE DLLs)
  - x32/*.dll (32-bit Windows PE DLLs)
- WhiskyKit/Wine.swift: enableDXVK() configures WINEDLLPATH for DXVK-macOS
- WhiskyKit/BottleSettings.swift: sets WINEDLLPATH when DXVK toggle is enabled

Manual usage
1. Bootstrap prefix (optional; requires wine on PATH):
   /bin/sh Brandywine/Scripts/dxvk-macos-bootstrap.sh

2. Run Wine with the launcher (after building the app):
   /path/to/Brandywine.app/Contents/MacOS/Brandywine-dxvk <wine-arguments>

Notes
- Paths inside the app bundle use: Contents/Resources/dxvk-macos
- This integration uses DXVK-macOS (Vulkan via MoltenVK). vkd3d-proton and GPTK are intentionally excluded.
- The scripts are POSIX sh compatible.
- DXVK_HUD and DXVK_ASYNC environment variables work with DXVK-macOS.

DXVK-macOS upstream: https://github.com/Gcenx/DXVK-macOS
Version: v1.10.3 (2023-05-07)
