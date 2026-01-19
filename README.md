# Bun.app

Chrome web app shortcut for bun.com

## Description

This is a macOS application bundle that creates a standalone desktop app for accessing bun.com. It uses Chrome's app mode to provide a dedicated browser window without the standard browser UI.

## Technical Details

- **Type**: Chrome App Mode Shortcut
- **Target URL**: https://bun.com/
- **Bundle ID**: com.google.Chrome.app.hfagfmadnhjmkmbmhaldlncjilakapnh
- **Executable**: app_mode_loader
- **Chrome Version**: 143.0.7499.193

## Structure

```
Bun.app/
├── Contents/
│   ├── Info.plist          # App metadata and configuration
│   ├── MacOS/
│   │   └── app_mode_loader # Chrome executable
│   ├── Resources/
│   │   ├── app.icns        # App icon
│   │   └── en-US.lproj/    # Localization files
│   ├── PkgInfo
│   └── _CodeSignature/     # Code signature data
```

## Usage

Double-click the app to launch bun.com in a dedicated Chrome window. The app behaves like a standalone desktop application while being powered by Chrome under the hood.

## Performance

- **Memory Usage**: ~56MB typical
- **CPU Usage**: ~0% when idle
- **Architecture**: ARM64 (Apple Silicon native)

## Requirements

- macOS 12.0+
- Google Chrome installed
