#!/bin/bash

# Simple script to create platform-specific release assets
set -e

echo "🚀 Creating Bun.app Release Assets"

VERSION="2.0.1"
DIST_DIR="./dist"

# Create dist directory
mkdir -p "$DIST_DIR"

# Create macOS package
echo "🍎 Building macOS package..."
mkdir -p "$DIST_DIR/temp-macos"
cp -r Contents "$DIST_DIR/temp-macos/" 2>/dev/null || echo "No Contents directory, skipping"
cp README.md "$DIST_DIR/temp-macos/" 2>/dev/null || echo "No README.md, skipping"
cp CHANGELOG.md "$DIST_DIR/temp-macos/" 2>/dev/null || echo "No CHANGELOG.md, skipping"
cp MIGRATION_GUIDE.md "$DIST_DIR/temp-macos/" 2>/dev/null || echo "No MIGRATION_GUIDE.md, skipping"
cp VERSION "$DIST_DIR/temp-macos/" 2>/dev/null || echo "No VERSION file, skipping"

# Copy all shell scripts
mkdir -p "$DIST_DIR/temp-macos/scripts"
find . -name "*.sh" -not -path "./dist/*" -not -path "./build/*" -exec cp {} "$DIST_DIR/temp-macos/scripts/" \;
find "$DIST_DIR/temp-macos/scripts" -name "*.sh" -exec chmod +x {} \;

# Create installer
cat > "$DIST_DIR/temp-macos/INSTALL.md" << 'EOF'
# Bun.app macOS Installation

## Quick Install
```bash
# Copy app to Applications
sudo cp -r Contents /Applications/Bun.app

# Install scripts to /usr/local/bin
sudo cp scripts/* /usr/local/bin/
```

## Features
- Native macOS app bundle
- Touch ID and Face ID support
- Enterprise security features
- Real time real-time collaboration
- AI-powered analytics

## Usage
```bash
# Run interactive demo
./scripts/enhanced-demo.sh quick

# Start security system
./scripts/auth-manager.sh init

# Start collaboration server
./scripts/collab-server.sh start
```
EOF

cd "$DIST_DIR"
tar -czf "bun-app-macos-$VERSION.tar.gz" temp-macos/
rm -rf temp-macos
cd ..

# Create Windows package
echo "🪟 Building Windows package..."
mkdir -p "$DIST_DIR/temp-windows"
cp README.md "$DIST_DIR/temp-windows/" 2>/dev/null || echo "No README.md, skipping"
cp CHANGELOG.md "$DIST_DIR/temp-windows/" 2>/dev/null || echo "No CHANGELOG.md, skipping"
cp MIGRATION_GUIDE.md "$DIST_DIR/temp-windows/" 2>/dev/null || echo "No MIGRATION_GUIDE.md, skipping"
cp VERSION "$DIST_DIR/temp-windows/" 2>/dev/null || echo "No VERSION file, skipping"

# Copy all shell scripts
mkdir -p "$DIST_DIR/temp-windows/scripts"
find . -name "*.sh" -not -path "./dist/*" -not -path "./build/*" -exec cp {} "$DIST_DIR/temp-windows/scripts/" \;
find "$DIST_DIR/temp-windows/scripts" -name "*.sh" -exec chmod +x {} \;

# Create Windows installer
cat > "$DIST_DIR/temp-windows/install.bat" << 'EOF'
@echo off
echo Installing Bun.app for Windows...

REM Create installation directory
if not exist "%PROGRAMFILES%\BunApp" mkdir "%PROGRAMFILES%\BunApp"

REM Copy files
xcopy /E /I /Y scripts "%PROGRAMFILES%\BunApp\scripts"
copy README.md "%PROGRAMFILES%\BunApp\" 2>nul
copy CHANGELOG.md "%PROGRAMFILES%\BunApp\" 2>nul
copy MIGRATION_GUIDE.md "%PROGRAMFILES%\BunApp\" 2>nul
copy VERSION "%PROGRAMFILES%\BunApp\" 2>nul

echo.
echo Installation complete!
echo.
echo To create Chrome app shortcut:
echo 1. Open Chrome
echo 2. Go to https://bun.com
echo 3. Click "More tools" > "Create shortcut"
echo 4. Name it "Bun App"
echo.
pause
EOF

cat > "$DIST_DIR/temp-windows/README.md" << 'EOF'
# Bun.app for Windows

## Installation
Run `install.bat` to install Bun.app.

## Features
- Chrome app mode support
- Enterprise security features
- Real time collaboration
- AI-powered analytics
- Plugin marketplace

## Usage
Use Git Bash or WSL to run shell scripts:
```bash
# Run interactive demo
./scripts/enhanced-demo.sh quick

# Start security system
./scripts/auth-manager.sh init

# Start collaboration server
./scripts/collab-server.sh start
```

## Chrome App Setup
1. Open Google Chrome
2. Navigate to https://bun.com
3. Click "More tools" > "Create shortcut"
4. Enter "Bun App" as name
5. Check "Open as window"
6. Click "Create"
EOF

cd "$DIST_DIR"
zip -r "bun-app-windows-$VERSION.zip" temp-windows/
rm -rf temp-windows
cd ..

# Create Linux package
echo "🐧 Building Linux package..."
mkdir -p "$DIST_DIR/temp-linux"
cp README.md "$DIST_DIR/temp-linux/" 2>/dev/null || echo "No README.md, skipping"
cp CHANGELOG.md "$DIST_DIR/temp-linux/" 2>/dev/null || echo "No CHANGELOG.md, skipping"
cp MIGRATION_GUIDE.md "$DIST_DIR/temp-linux/" 2>/dev/null || echo "No MIGRATION_GUIDE.md, skipping"
cp VERSION "$DIST_DIR/temp-linux/" 2>/dev/null || echo "No VERSION file, skipping"

# Copy all shell scripts
mkdir -p "$DIST_DIR/temp-linux/scripts"
find . -name "*.sh" -not -path "./dist/*" -not -path "./build/*" -exec cp {} "$DIST_DIR/temp-linux/scripts/" \;
find "$DIST_DIR/temp-linux/scripts" -name "*.sh" -exec chmod +x {} \;

# Create Linux installer
cat > "$DIST_DIR/temp-linux/install.sh" << 'EOF'
#!/bin/bash
echo "Installing Bun.app for Linux..."

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
cp *.md "$INSTALL_DIR/" 2>/dev/null || true
cp VERSION "$INSTALL_DIR/" 2>/dev/null || true

# Create symbolic links
for script in scripts/*.sh; do
    if [[ -f "$INSTALL_DIR/$script" ]]; then
        ln -sf "$INSTALL_DIR/$script" "$BIN_DIR/$(basename "$script" .sh)"
    fi
done

echo "Installation complete!"
echo "Files installed to $INSTALL_DIR"
echo "Scripts linked to $BIN_DIR"
EOF

chmod +x "$DIST_DIR/temp-linux/install.sh"

cat > "$DIST_DIR/temp-linux/README.md" << 'EOF'
# Bun.app for Linux

## Installation
Run `./install.sh` to install Bun.app.

## Features
- Native shell script support
- Enterprise security features
- Real time collaboration
- AI-powered analytics
- Plugin marketplace

## Usage
```bash
# Run interactive demo
./scripts/enhanced-demo.sh quick

# Start security system
./scripts/auth-manager.sh init

# Start collaboration server
./scripts/collab-server.sh start
```

## Chrome App Setup
1. Open Google Chrome
2. Navigate to https://bun.com
3. Click "More tools" > "Create shortcut"
4. Enter "Bun App" as name
5. Check "Open as window"
6. Click "Create"
EOF

cd "$DIST_DIR"
tar -czf "bun-app-linux-$VERSION.tar.gz" temp-linux/
rm -rf temp-linux
cd ..

# Create Chrome web app package
echo "🌐 Building Chrome package..."
mkdir -p "$DIST_DIR/temp-chrome"
cp README.md "$DIST_DIR/temp-chrome/" 2>/dev/null || echo "No README.md, skipping"
cp CHANGELOG.md "$DIST_DIR/temp-chrome/" 2>/dev/null || echo "No CHANGELOG.md, skipping"
cp MIGRATION_GUIDE.md "$DIST_DIR/temp-chrome/" 2>/dev/null || echo "No MIGRATION_GUIDE.md, skipping"
cp VERSION "$DIST_DIR/temp-chrome/" 2>/dev/null || echo "No VERSION file, skipping"

cat > "$DIST_DIR/temp-chrome/manifest.json" << EOF
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

cat > "$DIST_DIR/temp-chrome/README.md" << 'EOF'
# Bun App Chrome Web Application

## Installation

### Method 1: Create Shortcut (Recommended)
1. Open Google Chrome
2. Navigate to https://bun.com
3. Click "More tools" > "Create shortcut"
4. Enter "Bun App" as name
5. Check "Open as window"
6. Click "Create"

### Method 2: Load as Extension
1. Open Chrome and go to chrome://extensions/
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select this directory
5. Pin the extension to toolbar

## Features
- Bun.app enterprise platform
- Advanced security and collaboration
- AI-powered analytics
- Plugin marketplace
- Cross-platform support

## Enhanced Features
For advanced features like security systems, real-time collaboration, and AI analytics, see the full repository.
EOF

cd "$DIST_DIR"
zip -r "bun-app-chrome-$VERSION.zip" temp-chrome/
rm -rf temp-chrome
cd ..

# Create source code package
echo "📦 Creating source code package..."
cd ..
tar -czf "Bun.app/dist/bun-app-source-$VERSION.tar.gz" --exclude='.git' --exclude='dist' --exclude='build' --exclude='.DS_Store' Bun.app/
cd -

echo "✅ All release assets created!"
echo ""
echo "📦 Created packages:"
ls -la "$DIST_DIR/"
echo ""
echo "🚀 Ready to upload to GitHub releases!"
