#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TEAM_ID="${DEVELOPMENT_TEAM:-865A68ZY42}"

xcodebuild \
  -scheme Whisky \
  -configuration Debug \
  -destination 'platform=macOS' \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Automatic \
  build

echo ""
echo "Built: ~/Library/Developer/Xcode/DerivedData/Whisky-*/Build/Products/Debug/Whisky.app"
echo "Run: open \"$(find ~/Library/Developer/Xcode/DerivedData -path '*/Build/Products/Debug/Whisky.app' -maxdepth 6 2>/dev/null | head -1)\""
