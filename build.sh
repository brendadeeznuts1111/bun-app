#!/bin/bash

# Bun.app Build Script
# Creates Chrome web app shortcuts for macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_URL="https://bun.com/"
DEFAULT_NAME="Bun"
DEFAULT_ICON=""

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    echo "Usage: $0 [URL] [NAME] [ICON_PATH]"
    echo ""
    echo "Arguments:"
    echo "  URL        Target website URL (default: $DEFAULT_URL)"
    echo "  NAME       App name (default: $DEFAULT_NAME)"
    echo "  ICON_PATH  Path to .icns icon file (optional)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 'https://github.com' 'GitHub'"
    echo "  $0 'https://example.com' 'MyApp' '/path/to/icon.icns'"
    exit 1
}

# Parse arguments
URL="${1:-$DEFAULT_URL}"
NAME="${2:-$DEFAULT_NAME}"
ICON_PATH="${3:-$DEFAULT_ICON}"

# Validate URL
if [[ ! "$URL" =~ ^https?:// ]]; then
    print_error "URL must start with http:// or https://"
    usage
fi

# Check if Chrome is installed
check_chrome() {
    print_status "Checking Chrome installation..."
    
    if [[ -d "/Applications/Google Chrome.app" ]]; then
        CHROME_PATH="/Applications/Google Chrome.app"
        print_success "Chrome found at $CHROME_PATH"
    elif [[ -d "$HOME/Applications/Google Chrome.app" ]]; then
        CHROME_PATH="$HOME/Applications/Google Chrome.app"
        print_success "Chrome found at $CHROME_PATH"
    else
        print_error "Google Chrome not found. Please install Chrome first."
        exit 1
    fi
}

# Get Chrome version
get_chrome_version() {
    print_status "Getting Chrome version..."
    CHROME_VERSION=$(plutil -p "$CHROME_PATH/Contents/Info.plist" | grep CFBundleShortVersionString | cut -d'"' -f4)
    print_success "Chrome version: $CHROME_VERSION"
}

# Create app bundle structure
create_app_structure() {
    print_status "Creating app bundle structure..."
    
    APP_NAME="${NAME}.app"
    APP_DIR="$APP_NAME/Contents"
    
    # Remove existing app if it exists
    if [[ -d "$APP_NAME" ]]; then
        print_warning "Removing existing $APP_NAME"
        rm -rf "$APP_NAME"
    fi
    
    # Create directory structure
    mkdir -p "$APP_DIR/MacOS"
    mkdir -p "$APP_DIR/Resources"
    mkdir -p "$APP_DIR/Resources/en-US.lproj"
    mkdir -p "$APP_DIR/_CodeSignature"
    
    print_success "App bundle structure created"
}

# Generate unique bundle ID
generate_bundle_id() {
    print_status "Generating bundle ID..."
    
    # Create a unique ID based on URL and timestamp
    URL_HASH=$(echo "$URL" | md5sum | cut -c1-16)
    TIMESTAMP=$(date +%s)
    BUNDLE_ID="com.chrome.app.${URL_HASH}_${TIMESTAMP}"
    
    print_success "Bundle ID: $BUNDLE_ID"
}

# Create Info.plist
create_info_plist() {
    print_status "Creating Info.plist..."
    
    cat > "$APP_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>app_mode_loader</string>
    <key>CFBundleIconFile</key>
    <string>app.icns</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string></string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$CHROME_VERSION</string>
    <key>CrAppModeIsAdhocSigned</key>
    <true/>
    <key>CrAppModeShortcutID</key>
    <string>${BUNDLE_ID##*.}</string>
    <key>CrAppModeShortcutName</key>
    <string>$NAME</string>
    <key>CrAppModeShortcutURL</key>
    <string>$URL</string>
    <key>CrAppModeUserDataDir</key>
    <string>$HOME/Library/Application Support/Google/Chrome/-/Web Applications/_crx_${BUNDLE_ID##*.}</string>
    <key>CrBundleIdentifier</key>
    <string>com.google.Chrome</string>
    <key>CrBundleVersion</key>
    <string>$CHROME_VERSION</string>
    <key>DTCompiler</key>
    <string>com.apple.compilers.llvm.clang.1_0</string>
    <key>DTSDKBuild</key>
    <string>25A352</string>
    <key>DTSDKName</key>
    <string>macosx26.0</string>
    <key>DTXcode</key>
    <string>2601</string>
    <key>DTXcodeBuild</key>
    <string>17A400</string>
    <key>LSEnvironment</key>
    <dict>
        <key>MallocNanoZone</key>
        <string>0</string>
    </dict>
    <key>LSHasLocalizedDisplayName</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSAppleScriptEnabled</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF
    
    print_success "Info.plist created"
}

# Create PkgInfo
create_pkginfo() {
    print_status "Creating PkgInfo..."
    
    echo "APPL????" > "$APP_DIR/PkgInfo"
    
    print_success "PkgInfo created"
}

# Copy Chrome executable
copy_executable() {
    print_status "Copying Chrome executable..."
    
    cp "$CHROME_PATH/Contents/Frameworks/Google Chrome Framework.framework/Versions/$CHROME_VERSION/Helpers/app_mode_loader" "$APP_DIR/MacOS/"
    chmod +x "$APP_DIR/MacOS/app_mode_loader"
    
    print_success "Chrome executable copied"
}

# Handle icon
handle_icon() {
    print_status "Processing icon..."
    
    if [[ -n "$ICON_PATH" && -f "$ICON_PATH" ]]; then
        if [[ "$ICON_PATH" == *.icns ]]; then
            cp "$ICON_PATH" "$APP_DIR/Resources/app.icns"
            print_success "Custom icon copied"
        else
            print_warning "Icon must be in .icns format. Using default icon."
            create_default_icon
        fi
    else
        print_status "No icon provided, creating default icon"
        create_default_icon
    fi
}

# Create default icon (simple placeholder)
create_default_icon() {
    print_status "Creating default icon..."
    
    # For now, we'll create a minimal icon
    # In a real implementation, you might want to use iconutil or sips
    cat > "$APP_DIR/Resources/app.icns" << EOF
placeholder
EOF
    
    print_warning "Default placeholder icon created. Consider providing a proper .icns file."
}

# Create localization files
create_localization() {
    print_status "Creating localization files..."
    
    cat > "$APP_DIR/Resources/en-US.lproj/InfoPlist.strings" << EOF
/* Localized versions of Info.plist keys */

CFBundleName = "$NAME";
CFBundleDisplayName = "$NAME";
CFBundleSpokenName = "$NAME";
EOF
    
    print_success "Localization files created"
}

# Create code signature placeholder
create_code_signature() {
    print_status "Creating code signature placeholder..."
    
    cat > "$APP_DIR/_CodeSignature/CodeResources" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>files</key>
    <dict>
        <key>Resources/app.icns</key>
        <dict>
            <key>hash</key>
            <data>placeholder</data>
            <key>optional</key>
            <true/>
        </dict>
    </dict>
    <key>rules</key>
    <dict>
        <key>^Resources/</key>
        <true/>
        <key>^Resources/.*\.lproj/</key>
        <dict>
            <key>omit</key>
            <true/>
            <key>weight</key>
            <real>10</real>
        </dict>
        <key>^Resources/.*\.lproj/locversion.plist$</key>
        <dict>
            <key>omit</key>
            <true/>
            <key>weight</key>
            <real>30</real>
        </dict>
    </dict>
</dict>
</plist>
EOF
    
    print_success "Code signature placeholder created"
}

# Main build function
build_app() {
    print_status "Starting build process..."
    print_status "URL: $URL"
    print_status "Name: $NAME"
    
    check_chrome
    get_chrome_version
    generate_bundle_id
    create_app_structure
    create_info_plist
    create_pkginfo
    copy_executable
    handle_icon
    create_localization
    create_code_signature
    
    print_success "Build completed successfully!"
    print_status "App created: $APP_NAME"
    print_status "To install: cp -r '$APP_NAME' /Applications/"
    print_status "To launch: open '$APP_NAME'"
}

# Cleanup function
cleanup() {
    if [[ $? -ne 0 ]]; then
        print_error "Build failed. Cleaning up..."
        if [[ -d "$APP_NAME" ]]; then
            rm -rf "$APP_NAME"
        fi
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Run main build
build_app

print_success "All done! 🎉"
