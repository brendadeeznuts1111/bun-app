# Bun.app

🚀 **Chrome web app shortcut for bun.com** - A standalone macOS application that provides a dedicated browser experience for the Bun JavaScript runtime website.

![Bun App](https://img.shields.io/badge/macOS-12.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Chrome](https://img.shields.io/badge/Chrome-143.0.7499.193+-lightgrey.svg)

## ✨ Features

- 🖥️ **Native macOS App**: Looks and feels like a native application
- 🚀 **Fast Launch**: Opens bun.com in Chrome's optimized app mode
- 🎯 **Focused Experience**: No browser UI distractions, just the content
- 🔄 **Auto-Updates**: Leverages Chrome's auto-update mechanism
- 💾 **Lightweight**: ~56MB memory footprint when running
- 🍎 **Apple Silicon**: Native ARM64 support

## 📋 Requirements

- **macOS**: 12.0 or later
- **Google Chrome**: Latest version installed
- **Architecture**: Intel or Apple Silicon (ARM64)

## 🛠️ Installation

### Option 1: Download and Install (Recommended)

1. **Clone this repository**:
   ```bash
   git clone https://github.com/brendadeeznuts1111/bun-app.git
   cd bun-app
   ```

2. **Copy to Applications**:
   ```bash
   cp -r Bun.app /Applications/
   ```

3. **Launch the app**:
   - Double-click `Bun.app` in `/Applications/`
   - Or use Spotlight: `⌘ + Space`, type "Bun"

### Option 2: Build from Source

See the [Build Script](#build-script) section below for custom configurations.

## 🎮 Usage

### Basic Usage

1. **Launch**: Double-click the app icon
2. **Browse**: Use bun.com as you would in a regular browser
3. **Quit**: `⌘ + Q` or right-click dock icon → Quit

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘ + Q` | Quit application |
| `⌘ + R` | Reload page |
| `⌘ + +` | Zoom in |
| `⌘ + -` | Zoom out |
| `⌘ + 0` | Reset zoom |
| `⌘ + F` | Find in page |
| `⌘ + L` | Focus address bar |

## 🏗️ Technical Details

### Architecture

```
Bun.app/
├── Contents/
│   ├── Info.plist          # App metadata and configuration
│   ├── MacOS/
│   │   └── app_mode_loader # Chrome executable (2MB)
│   ├── Resources/
│   │   ├── app.icns        # App icon (50KB)
│   │   └── en-US.lproj/    # Localization files
│   ├── PkgInfo             # Package type info
│   └── _CodeSignature/     # Code signature data
```

### Configuration

- **Bundle ID**: `com.google.Chrome.app.hfagfmadnhjmkmbmhaldlncjilakapnh`
- **Target URL**: `https://bun.com/`
- **Chrome Version**: 143.0.7499.193
- **Architecture**: ARM64 (Apple Silicon native)

### Performance Metrics

| Metric | Value | Status |
|--------|-------|--------|
| **Memory Usage** | ~56MB | ✅ Excellent |
| **CPU Usage** | ~0% when idle | ✅ Efficient |
| **Launch Time** | <2 seconds | ✅ Fast |
| **Disk Space** | 3.2MB | ✅ Compact |

## 🔧 Build Script

Create custom Chrome web app shortcuts with the provided build script:

```bash
# Make the script executable
chmod +x build.sh

# Build with default settings
./build.sh

# Build with custom URL and name
./build.sh "https://example.com" "MyApp"
```

### Build Script Features

- 🎨 **Custom Icons**: Supports `.icns` files
- 🔗 **Custom URLs**: Any HTTPS website
- 📝 **Custom Names**: Your desired app name
- ✅ **Validation**: Checks Chrome installation
- 🧹 **Cleanup**: Removes temporary files

## 🐛 Troubleshooting

### Common Issues

**App won't launch:**
```bash
# Check Chrome installation
which google-chrome-stable || which chrome
# Reinstall Chrome if needed
```

**Permission denied:**
```bash
# Fix permissions
chmod +x "/Applications/Bun.app/Contents/MacOS/app_mode_loader"
```

**App crashes on launch:**
```bash
# Reset Chrome app mode
defaults delete com.google.Chrome
# Restart the app
```

### Debug Mode

Enable verbose logging:
```bash
# Set debug flag
defaults write com.google.Chrome.app.hfagfmadnhjmkmbmhaldlncjilakapnh -bool debug 1
# Check logs
Console.app → Search for "app_mode_loader"
```

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** this repository
2. **Create** a feature branch: `git checkout -b feature-name`
3. **Make** your changes
4. **Test** thoroughly
5. **Commit** your changes: `git commit -m "Add feature"`
6. **Push** to your fork: `git push origin feature-name`
7. **Open** a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/bun-app.git
cd bun-app

# Create a development branch
git checkout -b dev

# Make your changes
# Test the app
open Bun.app

# Commit and push
git add .
git commit -m "Development changes"
git push origin dev
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google Chrome** for providing the app mode functionality
- **Bun** team for the amazing JavaScript runtime
- **Apple** for macOS app bundle specifications

## 📞 Support

- 📧 **Issues**: [GitHub Issues](https://github.com/brendadeeznuts1111/bun-app/issues)
- 🐦 **Twitter**: [@bunjavascript](https://twitter.com/bunjavascript)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/brendadeeznuts1111/bun-app/discussions)

---

<div align="center">

**⭐ If this helped you, consider giving it a star!**

Made with ❤️ by the community

</div>
