# Brandywine Wine Features Guide

This guide covers the most popular Wine/Whisky features requested by the community, based on GitHub Issues and Discussions research.

## 1. Steam Compatibility (Most Popular - Issue #1338)

### The Problem
Steam fails with error 0x3008 or crashes on launch when using Wine 11.5.

### The Solution
Configure your bottle with:
- **Windows Version**: Windows 11 VM
- **Enhanced Sync**: MSYNC (improves stability and thread handling)
- **DXVK**: Enabled (hardware-accelerated graphics)

### How to Enable
1. In Brandywine, open the bottle's Config view
2. Set Windows Version to **Windows 11**
3. Set Enhanced Sync to **MSYNC**
4. Enable **DXVK** and set HUD to "Off"
5. Click "Control Panel" and configure Steam's graphics settings

### Manual Registry Fix
If Steam still doesn't launch:
```
1. Click "Regedit" in the Config bottom bar
2. Navigate to: HKEY_CURRENT_USER\Software\Wine\Direct3D
3. Create new String value: VideoMemorySize = 4096
4. Restart Steam
```

---

## 2. DXVK Configuration for Games

### What is DXVK?
DXVK is a Direct3D 9/10/11 to Vulkan translation layer that dramatically improves game compatibility and performance on macOS.

### Enable DXVK
In Bottle Config:
- Toggle **DXVK** to ON
- Set **DXVK HUD** to "Off" (or "FPS" to monitor frame rate)
- Enable **DXVK Async** for better performance (may cause issues in some games)

### DXVK HUD Options
- **Off**: No overlay
- **FPS**: Shows frame rate counter
- **Partial**: Shows basic GPU info
- **Full**: Shows detailed GPU, memory, and driver info

### For DirectX 9 Games
DirectX 9 games often need special configuration:
```
Registry (via Regedit):
HKEY_CURRENT_USER\Software\Wine\D3D9
- VideoMemorySize: 4096 (or higher for modern GPUs)
- CSMT: Enabled (better multi-threading)
```

---

## 3. Metal GPU Acceleration

### What is Metal?
Metal is macOS's native graphics API. Brandywine can use Metal via MoltenVK for better GPU performance.

### Enable Metal
In Bottle Config:
- Toggle **Metal HUD** to ON (shows GPU usage)
- Toggle **Metal Trace** to ON (advanced debugging)
- Toggle **DXR** to ON (if supported on your Mac)

### Metal HUD Information
Shows real-time GPU memory usage and rendering performance, useful for optimization.

---

## 4. Controller & Input Support (Issue #1332)

### The Problem
Controllers work in Whisky but Steam doesn't detect them properly.

### The Solution
1. **Enable MSYNC** in Config (Enhanced Sync setting)
2. **Use Windows 11** VM environment
3. **Configure controller in Steam**:
   - Open Big Picture mode
   - Go to Controller settings
   - Enable "Steam Input"
   - Test controller detection

### Xbox vs PlayStation Controllers
- **Xbox Controllers**: Usually work out of the box
- **PlayStation Controllers**: May need driver installation via winetricks
- **Generic Controllers**: Configure in Control Panel → Devices

### Manual Registry Configuration
```
Registry (Regedit):
HKEY_CURRENT_USER\Software\Wine\Joystick
- Enable: 1
- JoyNumButtons: 16
```

---

## 5. Audio Configuration (Sound Issues)

### Common Audio Problems
- No sound in games
- Crackling or distorted audio
- Audio lag or stuttering

### The Solution: PulseAudio
PulseAudio provides better audio support than ALSA:

```
Registry (via Regedit):
HKEY_CURRENT_USER\Software\Wine\Drivers
- Audio: "pulse" (or "pulseaudio")
```

### Audio Buffer Adjustment
For crackling audio:
```
Registry:
HKEY_CURRENT_USER\Software\Wine\Audio
- HelBuflen: 512
- SndQueueMax: 3
- HelFragmentSize: 128
```

### Troubleshooting
1. Check System Preferences → Sound → Output
2. Ensure the correct audio device is selected
3. Test audio with `afplay /System/Library/Sounds/Glass.aiff`
4. Restart the Wine bottle and try again

---

## 6. Advanced GPU Optimization

### DXVK HUD Monitoring
Enable DXVK HUD to see:
- Frame rate (FPS)
- GPU memory usage
- Draw calls per frame
- CPU/GPU timing

### Performance Tips
1. **Disable V-Sync**: Often improves frame rate
   ```
   Registry: HKEY_CURRENT_USER\Software\Wine\D3D
   - DirectDrawRenderer: opengl
   ```

2. **Enable Hardware Cursor**: Reduces input lag
   ```
   Registry: HKEY_CURRENT_USER\Software\Wine\Direct3D
   - HardwareCursor: enabled
   ```

3. **Adjust Render Scale**: Lower resolution for better FPS
   ```
   Registry: HKEY_CURRENT_USER\Software\Wine\DXVK
   - RenderScale: 0.8 (80% of native resolution)
   ```

### Monitor with Metal HUD
The Metal HUD in Config shows real-time GPU performance metrics.

---

## 7. DirectX 9 Game Optimization

### Common Issues
Many older games (2000s-2010s) use DirectX 9 and may need special configuration.

### Configuration
```
Registry:
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings
- ProxyEnable: 0

HKEY_CURRENT_USER\Software\Wine\D3D9
- VideoMemorySize: 4096
- CSMT: Enabled
```

### Recommended Settings for DX9 Games
- Windows XP SP3 OR Windows 10 (test both)
- DXVK: Enabled
- DXVK Async: Disabled (can cause crashes)
- Metal: Enabled

---

## 8. Windows Feature Installation (dotNET, Visual C++, DirectX)

### Using Winetricks
Many games require Windows components:

```bash
# .NET Framework
winetricks dotnet48

# Visual C++ Runtime
winetricks vcrun2022
winetricks vcrun2019
winetricks vcrun2015

# DirectX 9
winetricks d3dx9
```

### Via GUI
1. In Brandywine, click **Winetricks** button in Config
2. Search for the component (e.g., "dotnet48")
3. Click Install and wait for completion

---

## 9. Racing Wheel Support (Popular for Sim Racing)

### The Problem
Racing wheels not detected by games.

### The Solution
1. Enable **MSYNC** and **Windows 11**
2. Check wheel is recognized in System Preferences
3. Configure wheel in Control Panel:
   ```
   Control Panel → Game Controllers → Properties
   ```
4. Test wheel in Windows games via Winetricks test tool

### Manual Configuration
```
Registry:
HKEY_CURRENT_USER\Software\Wine\Joystick
- Enable: 1
- RawInput: 1 (for direct wheel input)
```

---

## 10. Game Launcher Support

### Steam
- Use Windows 11 + MSYNC configuration
- Enable Steam Input for controllers
- See "Steam Compatibility" section above

### Epic Games Launcher
```
Configuration:
- Windows 10 or 11
- DXVK Enabled
- MSYNC Enabled
```

### GOG Games
- Most GOG games work with standard configuration
- For older GOG games, use Windows XP SP3

### Game Pass
Not officially supported in Wine, but some games may work via workarounds.

---

## 11. Common Game-Specific Tweaks

### Cyberpunk 2077
- Windows 10, DXVK, MSYNC, Metal enabled
- Disable Ray Tracing
- Reduce resolution to 1440p for better performance

### Red Dead Redemption 2
- Windows 10, DXVK, Metal enabled
- Reduce resolution and graphic settings
- May have performance issues on lower-end Macs

### The Witcher 3
- Windows 10, DXVK enabled
- DXVK Async enabled
- Good performance on most Macs

### Skyrim & Mods
- Windows 10, DXVK enabled
- Install Visual C++ 2019 via winetricks
- Use Mod Organizer 2 via Wine

---

## 12. Troubleshooting Command Reference

### Test Audio
```bash
afplay /System/Library/Sounds/Glass.aiff
```

### Check Wine Version
```bash
wine --version
```

### Run Game with Debug Output
```bash
DXVK_DEBUG=all wine ./game.exe
```

### Monitor Performance
Use Metal HUD (Config → Toggle Metal HUD) for real-time GPU metrics.

---

## 13. Performance vs Compatibility Trade-offs

| Feature | Performance | Compatibility | Use Case |
|---------|------------|---------------|----------|
| DXVK | ⬆️ High | ✓ Good | Modern games |
| Metal | ⬆️ High | ✓ Good | macOS optimized |
| MSYNC | ↑ Medium | ✓ Excellent | Multi-threaded games |
| ESYNC | ↑ Medium | ⚠️ Unstable | Not recommended |
| Async DXVK | ⬆️⬆️ Very High | ⚠️ Risky | Demanding games (test first) |
| Windows XP | ↓ Lower | ✓ Very Good | Old DX9 games |

---

## Further Resources

- **Whisky GitHub**: https://github.com/Whisky-App/Whisky
- **Wine Wiki**: https://wiki.winehq.org/
- **DXVK Project**: https://github.com/doitsujin/dxvk
- **Winetricks**: https://github.com/Winetricks/winetricks
- **Wine Appdb**: https://appdb.winehq.org/ (game compatibility database)

---

**Last Updated**: April 2, 2026  
**Wine Version**: 11.5  
**Based on Community Requests from**: GitHub Issues #1338, #1332, #1317, and Discussions
