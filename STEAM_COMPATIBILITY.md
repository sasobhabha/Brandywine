# Steam Compatibility Layer - Wine 11.5

## Overview

Brandywine includes a comprehensive **Steam Compatibility Layer** that optimizes Wine 11.5 for running Steam and Steam games. This layer automatically applies critical registry settings, synchronization optimizations, and graphics acceleration.

## What the Compatibility Layer Does

When enabled, the Steam Compatibility Layer automatically configures:

### 1. Windows Environment
- **Windows Version**: Windows 11 VM environment for proper Steam API support
- **System Configuration**: Optimized virtual machine settings

### 2. Synchronization & Threading
- **MSYNC (Multi-Sync)**: Enhanced thread synchronization between Windows and Wine
  - Prevents race conditions in multi-threaded applications
  - Improves stability and reduces crashes
  - Critical for modern Steam applications

### 3. Graphics Acceleration
- **DXVK**: Direct3D to Vulkan translation layer
  - Hardware-accelerated graphics rendering
  - Better performance than software rendering
  - Supports DirectX 9-12 games

### 4. Registry Optimizations
The layer applies critical registry settings:
```
Direct3D Configuration:
  CSMT (Command Stream MultiThreading) = enabled
  Renderer = gl (OpenGL backend)
  VideoMemorySize = 4096 MB

Desktop Configuration:
  Default Resolution = 1920x1080

Driver Configuration:
  Managed Windows = Yes
  Window Decoration = Yes
```

## Using the Compatibility Layer

### Automatic Optimization (Recommended)

1. Open the bottle containing Steam
2. Go to **Config** tab
3. Look for **"Steam Compatibility Layer"** section
4. If not optimized, click **"Enable Steam Compatibility Layer"**
5. The layer will automatically:
   - Configure Windows 11
   - Enable MSYNC synchronization
   - Enable DXVK graphics
   - Apply registry optimizations

### Manual Configuration

If you prefer to configure manually:

1. **Windows Version**: Set to "Windows 11"
2. **Enhanced Sync**: Set to "MSYNC"
3. **DXVK**: Enable the toggle
4. **Registry**: Apply the critical keys listed below

## Advanced Registry Settings

For advanced users, these are the critical registry keys applied:

```
[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"CSMT"="enabled"
"Renderer"="gl"
"VideoMemorySize"="4096"

[HKEY_CURRENT_USER\Software\Wine\Explorer\Desktops]
"Default"="1920x1080"

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"Managed"="Y"
"Decorated"="Y"
```

## Troubleshooting

### Steam Won't Start
- Verify the Compatibility Layer is enabled (green checkmark)
- Ensure Windows 11, MSYNC, and DXVK are all enabled
- Try restarting the bottle

### Poor Game Performance
- Enable DXVK for hardware acceleration
- Increase Video Memory Size in Direct3D settings
- Disable unnecessary overlays

### Graphical Glitches
- Try enabling "Strict Shader Math" in Direct3D settings
- Disable DXVK if graphical corruption persists
- Update your GPU drivers

### Connection Issues
- Ensure network access is not restricted
- Check firewall settings for Steam
- Verify Internet connection inside the bottle

## Performance Tips

### For Best Performance:
1. **Enable DXVK** - Hardware graphics acceleration
2. **Use MSYNC** - Better thread synchronization
3. **Set Appropriate Resolution** - Match your display
4. **Allocate Sufficient Memory** - At least 4GB VRAM allocation
5. **Enable Retina Mode** - If using high-DPI displays

### For Compatibility:
1. Keep CSMT enabled for multi-threaded rendering
2. Use OpenGL (gl) renderer for compatibility
3. Enable Window Management (Managed=Y)
4. Use 64-bit Steam installation when possible

## Known Limitations

- **Windows 8.1 Support Ending**: Steam will eventually drop Windows 8.1 support, so Windows 11 is future-proof
- **Some Games May Require Tweaks**: Not all games work perfectly; check the Wine AppDB
- **Performance Varies**: Performance depends on your Mac's hardware capabilities

## Related Resources

- [Wine Registry Configuration](https://wiki.winehq.org/UsefulRegistryKeys)
- [DXVK Project](https://github.com/doitsujin/dxvk)
- [Steam on Wine AppDB](https://appdb.winehq.org)
- [Brandywine Documentation](https://docs.getwhisky.app)

## Support

If you encounter issues:
1. Check this guide's Troubleshooting section
2. Review the Wine AppDB for your specific game
3. Check bottle logs in the Terminal
4. Report issues with detailed system information


