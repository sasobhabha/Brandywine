# Popular Requested Features Guide

This document describes popular features requested by the Whisky/Brandywine community, as discovered from GitHub Issues and Discussions.

## 1. Controller/Gamepad Support (Issue #1332)

**Problem**: Controllers work in Whisky but are not detected by Steam or some games.

**Status**: Supported via MSYNC and Windows 11 configuration

**Solution**:
- Navigate to Bottle → Config
- Ensure **EnhancedSync** is set to "MSYNC" for controller support
- Configure bottle to use **Windows 11** VM environment
- In winecfg (Config → Control Panel), enable raw input for games

**Technical Details**:
- Controllers require proper input redirection through Wine
- MSYNC significantly improves controller responsiveness
- Some controllers may need Steam Input enabled in Steam settings

**Workaround for detection issues**:
```bash
# In the bottle directory, create/modify:
# ~/.config/Whisky/Bottles/{BottleName}/drive_c/windows/win.ini

[Joystick]
Enable=1
JoyNumButtons=16
```

---

## 2. Audio/Sound Configuration (Multiple Reports)

**Problem**: Many users report sound issues, crackling, or no audio in games.

**Status**: Partially configurable through registry tweaks

**Solutions**:

### A. PulseAudio Configuration
In winecfg Registry Editor:
```
HKEY_CURRENT_USER\Software\Wine\Drivers
Value: Audio = "pulseaudio"
```

### B. Audio Device Settings
```bash
# Test audio device:
aplay -l

# Set default device in ~/.asoundrc
pcm.!default {
    type pulse
}

ctl.!default {
    type pulse
}
```

### C. ALSA Settings
Registry (winecfg):
```
HKEY_CURRENT_USER\Software\Wine\Drivers
Value: Audio = "alsa"
```

### D. Common Troubleshooting
- Enable "Exclusive Mode" for audio device in regedit
- Adjust audio buffer size for crackling issues
- Check macOS audio routing and permissions

---

## 3. Custom Environment Variables

**Status**: Manual registry configuration required

**How to set environment variables**:

### Method 1: Registry Editor (winecfg)
1. Open Config → Inspect DPI (or Control Panel button)
2. Click "Regedit" button
3. Navigate to: `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment`
4. Right-click and create new String values

### Method 2: Via Command Line
```bash
# Through Wine directly:
wine cmd /c set VARIABLE_NAME=value

# Or modify system environment in registry:
HKEY_CURRENT_USER\Environment
```

**Common Variables**:
- `DXVK_DEBUG=all` - Enable DXVK debugging
- `WINE_CPU_TOPOLOGY=4:2` - Set CPU topology
- `GALLIUM_DRIVER=llvmpipe` - Force software rendering
- `STAGING_SHARED_MEMORY=1` - Enable shared memory

---

## 4. Windows Features & Dependencies (.NET, Visual C++, DirectX)

**Status**: Manual installation via winetricks or direct downloads

**Popular Installers**:

### .NET Framework
```bash
# Via Winetricks:
winetricks dotnet48

# Or download and install:
https://www.microsoft.com/download/details.aspx?id=30653
```

### Visual C++ Redist
```bash
# Multiple versions available:
winetricks vcrun2019
winetricks vcrun2022
```

### DirectX
```bash
# Install via Winetricks:
winetricks dxvk
winetricks d3dx9
```

### .NET 5/6/7/8
See: https://github.com/madewokherd/wine-mono and https://appdb.winehq.org/

**Installation Steps**:
1. Open WinetricksView (Config → Winetricks button)
2. Search for the component (e.g., "dotnet48")
3. Select and click "Install"
4. Wait for download and installation

---

## 5. Steam-Specific Issues

### Steam Won't Launch (Error 0x3008)
**Solution**: Use Windows 11 + MSYNC configuration (see Steam Compatibility Guide)

### Steam Input Not Working
- Ensure MSYNC is enabled in bottle config
- Enable "Steam Input" in Steam settings
- Verify controller in Big Picture mode

### Steam Download Issues
- Check internet connection
- Verify disk space (at least 10GB free)
- Try "Repair" in Steam settings

---

## 6. Game-Specific Tweaks

###  DirectX 9 Games
```
Registry (DXVK settings):
HKEY_CURRENT_USER\Software\Wine\DXVK
- d3d9=enabled
- dxvk_hud=off (or fps to show FPS)
```

### Older Games (DirectX 8 or earlier)
```
- Use Windows XP SP3 compatibility mode
- Disable Visual Themes
- Disable Desktop Composition
```

###  Games Requiring Specific .NET
```
winetricks dotnet20
winetricks dotnet35
winetricks dotnet40
winetricks dotnet461
```

---

## 7. Performance Optimization

### GPU Acceleration
- Enable DXVK (Config → DXVK section)
- Use Metal backend if available (Config → Metal section)

### CPU Performance
- Enable AVX if supported (Config → AVX, macOS 15+)
- Adjust MSYNC settings for compatibility

### Memory Management
```bash
# In registry, increase available memory:
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
Value: NtGlobalFlag = dword:000000 (remove debug flags)
```

---

## 8. Troubleshooting Common Issues

| Issue | Solution |
|-------|----------|
| No Sound | Enable PulseAudio, check device in System Preferences |
| Controller Not Detected | Enable MSYNC, verify in regedit |
| Game Won't Start | Check .NET dependencies, try Windows 8.1 mode |
| Crashes on Startup | Disable DXVK async, try software rendering |
| Poor Performance | Enable DXVK, disable Metal HUD, check CPU cores |

---

## References

- GitHub Issues: https://github.com/Whisky-App/Whisky/issues
- Wine Documentation: https://wiki.winehq.org/
- DXVK: https://github.com/doitsujin/dxvk
- Winetricks: https://github.com/Winetricks/winetricks

---

For more help, see [STEAM_COMPATIBILITY.md](./STEAM_COMPATIBILITY.md) for Steam-specific issues.
