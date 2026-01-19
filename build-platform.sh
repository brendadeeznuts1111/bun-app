#!/bin/bash

# Platform-specific build script for Bun.app
# Creates distribution packages for different operating systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
DIST_DIR="$PROJECT_DIR/dist"
VERSION=$(cat "$PROJECT_DIR/VERSION" 2>/dev/null || echo "2.0.1")

# Parse command line arguments
parse_args() {
    COMMAND=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            --platform|-p)
                PLATFORM="$2"
                shift 2
                ;;
            --arch|-a)
                ARCH="$2"
                shift 2
                ;;
            --output|-o)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --clean|-c)
                CLEAN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            all|macos|windows|linux|chrome|help)
                COMMAND="$1"
                shift
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
🏗️  Bun.app Platform-Specific Builder

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    all                    Build for all platforms
    macos                  Build macOS package
    windows                Build Windows package
    linux                  Build Linux package
    chrome                 Build Chrome web app package

OPTIONS:
    -p, --platform PLATFORM Target platform (macos, windows, linux, chrome)
    -a, --arch ARCH         Target architecture (x64, arm64)
    -o, --output DIR        Output directory (default: ./dist)
    -c, --clean            Clean build directory first
    -h, --help             Show this help

EXAMPLES:
    $0 all                 # Build all platform packages
    $0 macos               # Build macOS package only
    $0 windows --arch x64  # Build Windows x64 package
    $0 linux --arch arm64  # Build Linux ARM64 package

SUPPORTED PLATFORMS:
- macOS (x64, arm64) - Native app bundle
- Windows (x64) - Chrome app mode + scripts
- Linux (x64, arm64) - Chrome app mode + scripts
- Chrome (universal) - Web app package

EOF
}

# Detect current platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Detect current architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64)
            echo "x64"
            ;;
        arm64|aarch64)
            echo "arm64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Clean build directories
clean_build() {
    echo -e "${BLUE}🧹 Cleaning build directories...${NC}"
    rm -rf "$BUILD_DIR"
    rm -rf "$DIST_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$DIST_DIR"
}

# Build macOS package
build_macos() {
    local arch="${1:-$(detect_arch)}"
    echo -e "${GREEN}🍎 Building macOS package ($arch)...${NC}"
    
    local pkg_name="bun-app-macos-$arch-$VERSION"
    local pkg_dir="$BUILD_DIR/$pkg_name"
    
    # Create package directory
    mkdir -p "$pkg_dir"
    
    # Copy macOS app bundle
    if [[ -d "$PROJECT_DIR/Contents" ]]; then
        cp -r "$PROJECT_DIR/Contents" "$pkg_dir/"
    fi
    
    # Copy shell scripts with proper permissions
    mkdir -p "$pkg_dir/scripts"
    find "$PROJECT_DIR" -name "*.sh" -type f -not -path "*/build/*" -exec cp {} "$pkg_dir/scripts/" \;
    find "$pkg_dir/scripts" -name "*.sh" -type f -exec chmod +x {} \;
    
    # Copy documentation
    cp "$PROJECT_DIR/README.md" "$pkg_dir/" 2>/dev/null || echo "README.md not found, skipping"
    cp "$PROJECT_DIR/CHANGELOG.md" "$pkg_dir/" 2>/dev/null || echo "CHANGELOG.md not found, skipping"
    cp "$PROJECT_DIR/MIGRATION_GUIDE.md" "$pkg_dir/" 2>/dev/null || echo "MIGRATION_GUIDE.md not found, skipping"
    cp "$PROJECT_DIR/VERSION" "$pkg_dir/" 2>/dev/null || echo "VERSION not found, skipping"
    
    # Copy configuration files
    if [[ -d "$PROJECT_DIR/config" ]]; then
        cp -r "$PROJECT_DIR/config" "$pkg_dir/"
    fi
    
    # Create macOS installer script
    cat > "$pkg_dir/install.sh" << 'EOF'
#!/bin/bash
# Bun.app macOS Installer
set -e

echo "🍎 Installing Bun.app for macOS..."

# Copy app bundle to Applications
if [[ -d "Contents" ]]; then
    sudo cp -r Contents /Applications/Bun.app
    echo "✅ App bundle installed to /Applications/Bun.app"
fi

# Install shell scripts
if [[ -d "scripts" ]]; then
    mkdir -p /usr/local/bin/bun-app
    cp scripts/* /usr/local/bin/bun-app/
    echo "✅ Scripts installed to /usr/local/bin/bun-app/"
fi

# Set permissions
chmod +x /usr/local/bin/bun-app/*.sh 2>/dev/null || true

echo "🎉 Installation complete!"
echo "📖 See README.md for usage instructions"
EOF
    
    chmod +x "$pkg_dir/install.sh"
    
    # Create package archive
    cd "$BUILD_DIR"
    tar -czf "$DIST_DIR/$pkg_name.tar.gz" "$pkg_name"
    
    echo -e "${GREEN}✅ macOS package created: $DIST_DIR/$pkg_name.tar.gz${NC}"
}

# Build Windows package
build_windows() {
    local arch="${1:-x64}"
    echo -e "${GREEN}🪟 Building Windows package ($arch)...${NC}"
    
    local pkg_name="bun-app-windows-$arch-$VERSION"
    local pkg_dir="$BUILD_DIR/$pkg_name"
    
    # Create package directory
    mkdir -p "$pkg_dir"
    
    # Copy shell scripts (for Git Bash/WSL)
    mkdir -p "$pkg_dir/scripts"
    find "$PROJECT_DIR" -name "*.sh" -type f -not -path "*/build/*" -exec cp {} "$pkg_dir/scripts/" \;
    find "$pkg_dir/scripts" -name "*.sh" -type f -exec chmod +x {} \;
    
    # Copy documentation
    cp "$PROJECT_DIR/README.md" "$pkg_dir/"
    cp "$PROJECT_DIR/CHANGELOG.md" "$pkg_dir/"
    cp "$PROJECT_DIR/MIGRATION_GUIDE.md" "$pkg_dir/"
    cp "$PROJECT_DIR/VERSION" "$pkg_dir/"
    
    # Create Windows batch files
    cat > "$pkg_dir/install.bat" << 'EOF'
@echo off
echo 🪟 Installing Bun.app for Windows...

REM Create installation directory
if not exist "%PROGRAMFILES%\BunApp" mkdir "%PROGRAMFILES%\BunApp"

REM Copy files
xcopy /E /I /Y scripts "%PROGRAMFILES%\BunApp\scripts"
copy README.md "%PROGRAMFILES%\BunApp\"
copy CHANGELOG.md "%PROGRAMFILES%\BunApp\"
copy MIGRATION_GUIDE.md "%PROGRAMFILES%\BunApp\"
copy VERSION "%PROGRAMFILES%\BunApp\"

REM Add to PATH (optional)
echo.
echo 📖 Installation complete!
echo 💻 Use Git Bash or WSL to run shell scripts
echo 📖 See README.md for usage instructions
echo.
echo 🌐 To create Chrome app shortcut:
echo 1. Open Chrome
echo 2. Navigate to your target URL
echo 3. Click "More tools" > "Create shortcut"
echo 4. Name it "Bun App"
echo.
pause
EOF
    
    # Create Chrome app shortcut creator
    cat > "$pkg_dir/create-chrome-app.bat" << 'EOF'
@echo off
echo 🌐 Creating Bun.app Chrome shortcut...

set /p url="Enter target URL (or press Enter for default): "
if "%url%"=="" set url=https://bun.com

echo.
echo 📋 Instructions:
echo 1. Open Google Chrome
echo 2. Navigate to: %url%
echo 3. Click "More tools" > "Create shortcut"
echo 4. Enter "Bun App" as name
echo 5. Check "Open as window"
echo 6. Click "Create"
echo.
pause
EOF
    
    # Create package archive
    cd "$BUILD_DIR"
    zip -r "$DIST_DIR/$pkg_name.zip" "$pkg_name"
    
    echo -e "${GREEN}✅ Windows package created: $DIST_DIR/$pkg_name.zip${NC}"
}

# Build Linux package
build_linux() {
    local arch="${1:-$(detect_arch)}"
    echo -e "${GREEN}🐧 Building Linux package ($arch)...${NC}"
    
    local pkg_name="bun-app-linux-$arch-$VERSION"
    local pkg_dir="$BUILD_DIR/$pkg_name"
    
    # Create package directory
    mkdir -p "$pkg_dir"
    
    # Copy shell scripts
    mkdir -p "$pkg_dir/scripts"
    find "$PROJECT_DIR" -name "*.sh" -type f -not -path "*/build/*" -exec cp {} "$pkg_dir/scripts/" \;
    find "$pkg_dir/scripts" -name "*.sh" -type f -exec chmod +x {} \;
    
    # Copy documentation
    cp "$PROJECT_DIR/README.md" "$pkg_dir/"
    cp "$PROJECT_DIR/CHANGELOG.md" "$pkg_dir/"
    cp "$PROJECT_DIR/MIGRATION_GUIDE.md" "$pkg_dir/"
    cp "$PROJECT_DIR/VERSION" "$pkg_dir/"
    
    # Copy configuration files
    if [[ -d "$PROJECT_DIR/config" ]]; then
        cp -r "$PROJECT_DIR/config" "$pkg_dir/"
    fi
    
    # Create Linux installer script
    cat > "$pkg_dir/install.sh" << 'EOF'
#!/bin/bash
# Bun.app Linux Installer
set -e

echo "🐧 Installing Bun.app for Linux..."

# Check if running as root for system-wide installation
if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/opt/bun-app"
    BIN_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/share/bun-app"
    BIN_DIR="$HOME/.local/bin"
fi

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Copy files
cp -r scripts "$INSTALL_DIR/"
cp *.md "$INSTALL_DIR/"
cp VERSION "$INSTALL_DIR/"

# Create symbolic links
for script in scripts/*.sh; do
    if [[ -f "$INSTALL_DIR/$script" ]]; then
        ln -sf "$INSTALL_DIR/$script" "$BIN_DIR/$(basename "$script" .sh)"
    fi
done

echo "✅ Files installed to $INSTALL_DIR"
echo "✅ Scripts linked to $BIN_DIR"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> ~/.bashrc
    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> ~/.zshrc 2>/dev/null || true
fi

echo "🎉 Installation complete!"
echo "📖 See README.md for usage instructions"
echo "🔄 Run 'source ~/.bashrc' or restart terminal to update PATH"
EOF
    
    chmod +x "$pkg_dir/install.sh"
    
    # Create Chrome app desktop entry
    cat > "$pkg_dir/bun-app.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Bun App
Comment=Enterprise-Grade Chrome Web Application Platform
Exec=google-chrome --app=https://bun.com
Icon=applications-internet
Terminal=false
Categories=Development;Office;
EOF
    
    # Create package archive
    cd "$BUILD_DIR"
    tar -czf "$DIST_DIR/$pkg_name.tar.gz" "$pkg_name"
    
    echo -e "${GREEN}✅ Linux package created: $DIST_DIR/$pkg_name.tar.gz${NC}"
}

# Build Chrome web app package
build_chrome() {
    echo -e "${GREEN}🌐 Building Chrome web app package...${NC}"
    
    local pkg_name="bun-app-chrome-$VERSION"
    local pkg_dir="$BUILD_DIR/$pkg_name"
    
    # Create package directory
    mkdir -p "$pkg_dir"
    
    # Copy core files
    cp "$PROJECT_DIR/README.md" "$pkg_dir/"
    cp "$PROJECT_DIR/CHANGELOG.md" "$pkg_dir/"
    cp "$PROJECT_DIR/MIGRATION_GUIDE.md" "$pkg_dir/"
    cp "$PROJECT_DIR/VERSION" "$pkg_dir/"
    
    # Create Chrome app manifest
    cat > "$pkg_dir/manifest.json" << EOF
{
  "name": "Bun App",
  "version": "$VERSION",
  "description": "Enterprise-Grade Chrome Web Application Platform",
  "manifest_version": 3,
  "app": {
    "urls": ["https://bun.com"],
    "launch": {
      "web_url": "https://bun.com"
    }
  },
  "icons": {
    "128": "icon-128.png"
  },
  "permissions": [
    "storage",
    "notifications"
  ],
  "offline_enabled": true
}
EOF
    
    # Create installation instructions
    cat > "$pkg_dir/CHROME_INSTALL.md" << EOF
# Chrome App Installation

## Method 1: Create Shortcut (Recommended)
1. Open Google Chrome
2. Navigate to https://bun.com
3. Click "More tools" > "Create shortcut"
4. Enter "Bun App" as name
5. Check "Open as window"
6. Click "Create"

## Method 2: Load as Extension
1. Open Chrome and go to chrome://extensions/
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select this directory
5. Pin the extension to toolbar

## Method 3: Install from Web Store
Coming soon - will be published to Chrome Web Store

## Features
- Enterprise-grade security and collaboration
- Real-time features and AI analytics
- Plugin marketplace and extensibility
- Cross-platform compatibility

For advanced features, see the enhanced systems in the main repository.
EOF
    
    # Create package archive
    cd "$BUILD_DIR"
    zip -r "$DIST_DIR/$pkg_name.zip" "$pkg_name"
    
    echo -e "${GREEN}✅ Chrome package created: $DIST_DIR/$pkg_name.zip${NC}"
}

# Build all platforms
build_all() {
    echo -e "${BOLD}🌍 Building for all platforms...${NC}"
    
    # Build macOS packages
    build_macos x64
    build_macos arm64
    
    # Build Windows package
    build_windows x64
    
    # Build Linux packages
    build_linux x64
    build_linux arm64
    
    # Build Chrome package
    build_chrome
    
    echo -e "${BOLD}🎉 All platform builds completed!${NC}"
    echo -e "${BLUE}📦 Packages available in: $DIST_DIR${NC}"
    
    # List created packages
    echo -e "\n${BOLD}📋 Created Packages:${NC}"
    ls -la "$DIST_DIR/"
}

# Main function
main() {
    # Parse arguments
    parse_args "$@"
    
    # Set defaults
    PLATFORM="${PLATFORM:-$(detect_platform)}"
    ARCH="${ARCH:-$(detect_arch)}"
    OUTPUT_DIR="${OUTPUT_DIR:-$DIST_DIR}"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Clean if requested
    if [[ "$CLEAN" == true ]]; then
        clean_build
    fi
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Handle commands
    case "${COMMAND:-help}" in
        "all")
            build_all
            ;;
        "macos")
            build_macos "$ARCH"
            ;;
        "windows")
            build_windows "$ARCH"
            ;;
        "linux")
            build_linux "$ARCH"
            ;;
        "chrome")
            build_chrome
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Handle script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
