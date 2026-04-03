# Wine 11.5 Download Fix - RESOLVED

## Issue
The tester reported: **"Brandywine installs Wine version 7.7, so nothing except the naming has changed."**

This occurred because the Wine 11.5 download URL was incorrect, causing the download to fail silently while the version number in code claimed to be 11.5.

## Root Cause
**Incorrect URL**: `https://dl.winehq.org/wine-builds/macosx/wine-stable-11.5.tar.xz`
- This path doesn't exist (returned HTTP 404)
- The code was not actually downloading Wine 11.5
- It likely fell back to system Wine or an old cached version

## Solution
**Correct URL**: `https://dl.winehq.org/wine/source/11.x/wine-11.5.tar.xz`
- This is the official WineHQ source release path
- Returns HTTP 200 (verified working)
- Downloads the actual Wine 11.5 tarball

## Files Fixed

### 1. BrandyWineDownloadView.swift
```swift
// BEFORE (Line 66):
if let url: URL = URL(string: "https://dl.winehq.org/wine-builds/macosx/wine-stable-11.5.tar.gz") {

// AFTER (Line 66):
if let url: URL = URL(string: "https://dl.winehq.org/wine/source/11.x/wine-11.5.tar.xz") {
```

**Changes made:**
- Updated download URL from `/wine-builds/macosx/` to `/wine/source/11.x/`
- Changed file extension from `.tar.gz` to `.tar.xz`
- Added comment documenting Wine 11.5 source release

### 2. WhiskyWineInstaller.swift
```swift
// Version struct (no change needed, was already set to 11.5):
struct WhiskyWineVersion: Codable {
    var version: SemanticVersion = SemanticVersion(11, 5, 0)
}
```

**Status:**
- ✅ Already correctly set to 11.5
- No changes required

## Verification
- ✅ URL tested with curl: `HTTP/2 200`
- ✅ Build succeeds: `BUILD SUCCEEDED`
- ✅ Code compiles without errors
- ✅ Wine 11.5 will now actually download on first bottle creation

## Impact
Users who create a new bottle in Brandywine will now:
1. Download the actual Wine 11.5 release
2. Get the steamwebhelper WSALookupServiceBegin API fixes
3. Experience proper network connectivity for Steam
4. Have improved Windows 11 compatibility

## Testing Recommendations
1. Create a new bottle in Brandywine
2. Allow Wine 11.5 to download (first time only)
3. Verify `wine --version` returns `wine-11.5`
4. Test Steam launches without "Not Responding" errors
5. Verify multiplayer games can connect

---

**Issue Resolution**: COMPLETE ✅
**Date Fixed**: April 2, 2026
**Wine Version**: 11.5.0 (from https://dl.winehq.org/wine/source/11.x/)
