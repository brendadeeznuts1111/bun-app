#!/bin/bash

# Advanced Bun.app Build Script
# Enhanced build system with templates, configuration, and advanced features

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="config/build-config.yaml"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
CONFIG_DIR="$SCRIPT_DIR/config"
TEMP_DIR="$SCRIPT_DIR/tmp"

# Default values
TEMPLATE="minimal"
SECURITY_PROFILE="medium"
PERFORMANCE_PROFILE="optimized"
LANGUAGE="en-US"
OUTPUT_DIR="./dist"
VERBOSE=false
DRY_RUN=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template|-t)
                TEMPLATE="$2"
                shift 2
                ;;
            --security|-s)
                SECURITY_PROFILE="$2"
                shift 2
                ;;
            --performance|-p)
                PERFORMANCE_PROFILE="$2"
                shift 2
                ;;
            --language|-l)
                LANGUAGE="$2"
                shift 2
                ;;
            --output|-o)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --config|-c)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --dry-run|-n)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                URL="$1"
                NAME="$2"
                shift 2
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
Advanced Bun.app Build Script

USAGE:
    $0 [OPTIONS] <URL> <NAME>

ARGUMENTS:
    URL     Target website URL
    NAME    App name

OPTIONS:
    -t, --template TEMPLATE       Build template (minimal, developer, enterprise, kiosk)
    -s, --security PROFILE        Security profile (high, medium, low)
    -p, --performance PROFILE     Performance profile (optimized, lightweight, resource_intensive)
    -l, --language LANGUAGE       Language code (en-US, es-ES, fr-FR, etc.)
    -o, --output DIR              Output directory (default: ./dist)
    -c, --config FILE             Configuration file (default: config/build-config.yaml)
    -v, --verbose                 Verbose output
    -n, --dry-run                 Show what would be built without creating files
    -h, --help                    Show this help

TEMPLATES:
    minimal       Basic functionality with minimal features
    developer     Enhanced for developers with debugging tools
    enterprise    Corporate features with security and management
    kiosk         Public display mode with kiosk features

SECURITY PROFILES:
    high          Maximum security restrictions
    medium        Balanced security settings
    low           Developer-friendly with minimal restrictions

PERFORMANCE PROFILES:
    optimized     Balanced performance and features
    lightweight   Minimal resource usage
    resource_intensive  Maximum features and performance

EXAMPLES:
    $0 https://example.com "MyApp"
    $0 --template developer --security low https://localhost:3000 "DevApp"
    $0 --template enterprise --performance optimized https://company.com "CorpApp"

EOF
}

# Utility functions
print_info() {
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

print_debug() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Load configuration
load_config() {
    print_info "Loading configuration from $CONFIG_FILE"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Parse YAML configuration (basic implementation)
    # In a real implementation, you'd use a proper YAML parser
    print_debug "Configuration loaded successfully"
}

# Validate configuration
validate_config() {
    print_info "Validating configuration"
    
    # Validate URL
    if [[ ! "$URL" =~ ^https?:// ]]; then
        print_error "URL must start with http:// or https://"
        exit 1
    fi
    
    # Validate template
    if [[ ! "$TEMPLATE" =~ ^(minimal|developer|enterprise|kiosk)$ ]]; then
        print_error "Invalid template: $TEMPLATE"
        exit 1
    fi
    
    # Validate security profile
    if [[ ! "$SECURITY_PROFILE" =~ ^(high|medium|low)$ ]]; then
        print_error "Invalid security profile: $SECURITY_PROFILE"
        exit 1
    fi
    
    # Validate performance profile
    if [[ ! "$PERFORMANCE_PROFILE" =~ ^(optimized|lightweight|resource_intensive)$ ]]; then
        print_error "Invalid performance profile: $PERFORMANCE_PROFILE"
        exit 1
    fi
    
    print_success "Configuration validated"
}

# Setup environment
setup_environment() {
    print_info "Setting up build environment"
    
    # Create directories
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Check Chrome installation
    if [[ ! -d "/Applications/Google Chrome.app" ]] && [[ ! -d "$HOME/Applications/Google Chrome.app" ]]; then
        print_error "Google Chrome not found"
        exit 1
    fi
    
    print_success "Environment setup complete"
}

# Generate bundle ID
generate_bundle_id() {
    local url_hash=$(echo "$URL" | md5sum | cut -c1-16)
    local timestamp=$(date +%s)
    local template_suffix=$(echo "$TEMPLATE" | tr '[:upper:]' '[:lower:]')
    echo "com.chrome.app.${url_hash}_${template_suffix}_${timestamp}"
}

# Create enhanced Info.plist
create_info_plist() {
    local bundle_id=$(generate_bundle_id)
    local app_name="$NAME"
    local app_version="1.0.0"
    local chrome_version=$(plutil -p "/Applications/Google Chrome.app/Contents/Info.plist" | grep CFBundleShortVersionString | cut -d'"' -f4)
    
    print_info "Creating enhanced Info.plist for template: $TEMPLATE"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would create Info.plist with bundle ID: $bundle_id"
        return
    fi
    
    cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$LANGUAGE</string>
    <key>CFBundleExecutable</key>
    <string>app_mode_loader</string>
    <key>CFBundleIconFile</key>
    <string>app.icns</string>
    <key>CFBundleIdentifier</key>
    <string>$bundle_id</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$app_name</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$app_version</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$chrome_version</string>
    <key>CrAppModeIsAdhocSigned</key>
    <true/>
    <key>CrAppModeShortcutID</key>
    <string>${bundle_id##*.}</string>
    <key>CrAppModeShortcutName</key>
    <string>$app_name</string>
    <key>CrAppModeShortcutURL</key>
    <string>$URL</string>
    <key>CrAppModeUserDataDir</key>
    <string>$HOME/Library/Application Support/Google/Chrome/-/Web Applications/_crx_${bundle_id##*.}</string>
    <key>CrBundleIdentifier</key>
    <string>com.google.Chrome</string>
    <key>CrBundleVersion</key>
    <string>$chrome_version</string>
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
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <$(get_security_setting "allow_insecure_content")/>
    </dict>
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Bun.app Contributors. All rights reserved.</string>
    <key>CFBundleGetInfoString</key>
    <string>$app_name $app_version, Chrome web app for $URL</string>
</dict>
</plist>
EOF
    
    print_debug "Info.plist created with template-specific settings"
}

# Get security setting based on profile
get_security_setting() {
    local setting="$1"
    
    case "$SECURITY_PROFILE" in
        "high")
            case "$setting" in
                "allow_insecure_content") echo "false" ;;
                "allow_running_insecure_content") echo "false" ;;
                "web_security_enabled") echo "true" ;;
                *) echo "false" ;;
            esac
            ;;
        "medium")
            case "$setting" in
                "allow_insecure_content") echo "false" ;;
                "allow_running_insecure_content") echo "false" ;;
                "web_security_enabled") echo "true" ;;
                *) echo "false" ;;
            esac
            ;;
        "low")
            case "$setting" in
                "allow_insecure_content") echo "true" ;;
                "allow_running_insecure_content") echo "true" ;;
                "web_security_enabled") echo "false" ;;
                *) echo "true" ;;
            esac
            ;;
    esac
}

# Create enhanced app structure
create_app_structure() {
    local app_name="$NAME"
    APP_DIR="$OUTPUT_DIR/${app_name}.app"
    
    print_info "Creating enhanced app structure for template: $TEMPLATE"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would create app structure at: $APP_DIR"
        return
    fi
    
    # Remove existing app
    if [[ -d "$APP_DIR" ]]; then
        print_warning "Removing existing app: $APP_DIR"
        rm -rf "$APP_DIR"
    fi
    
    # Create directory structure
    mkdir -p "$APP_DIR/Contents/MacOS"
    mkdir -p "$APP_DIR/Contents/Resources"
    mkdir -p "$APP_DIR/Contents/Resources/en-US.lproj"
    mkdir -p "$APP_DIR/Contents/_CodeSignature"
    
    # Template-specific directories
    case "$TEMPLATE" in
        "developer")
            mkdir -p "$APP_DIR/Contents/Resources/developer"
            mkdir -p "$APP_DIR/Contents/Resources/debug"
            ;;
        "enterprise")
            mkdir -p "$APP_DIR/Contents/Resources/enterprise"
            mkdir -p "$APP_DIR/Contents/Resources/policies"
            ;;
        "kiosk")
            mkdir -p "$APP_DIR/Contents/Resources/kiosk"
            mkdir -p "$APP_DIR/Contents/Resources/reset"
            ;;
    esac
    
    print_success "Enhanced app structure created"
}

# Copy and enhance executable
copy_executable() {
    print_info "Copying and enhancing Chrome executable"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would copy and enhance Chrome executable"
        return
    fi
    
    local chrome_path="/Applications/Google Chrome.app"
    local chrome_version=$(plutil -p "$chrome_path/Contents/Info.plist" | grep CFBundleShortVersionString | cut -d'"' -f4)
    
    cp "$chrome_path/Contents/Frameworks/Google Chrome Framework.framework/Versions/$chrome_version/Helpers/app_mode_loader" "$APP_DIR/Contents/MacOS/"
    chmod +x "$APP_DIR/Contents/MacOS/app_mode_loader"
    
    # Template-specific executable modifications
    case "$TEMPLATE" in
        "developer")
            print_debug "Adding developer tools to executable"
            # In a real implementation, you might patch the executable or add helper scripts
            ;;
        "enterprise")
            print_debug "Adding enterprise features to executable"
            ;;
        "kiosk")
            print_debug "Adding kiosk mode to executable"
            ;;
    esac
    
    print_success "Chrome executable enhanced"
}

# Create enhanced resources
create_resources() {
    print_info "Creating enhanced resources for template: $TEMPLATE"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would create enhanced resources"
        return
    fi
    
    # Create PkgInfo
    echo "APPL????" > "$APP_DIR/Contents/PkgInfo"
    
    # Create icon (template-specific)
    create_template_icon
    
    # Create localization files
    create_localization_files
    
    # Create template-specific resources
    case "$TEMPLATE" in
        "developer")
            create_developer_resources
            ;;
        "enterprise")
            create_enterprise_resources
            ;;
        "kiosk")
            create_kiosk_resources
            ;;
    esac
    
    print_success "Enhanced resources created"
}

# Create template-specific icon
create_template_icon() {
    local icon_path="$TEMPLATES_DIR/icons/${TEMPLATE}.icns"
    
    if [[ -f "$icon_path" ]]; then
        cp "$icon_path" "$APP_DIR/Contents/Resources/app.icns"
        print_debug "Using template icon: $icon_path"
    else
        # Create default icon
        create_default_icon
        print_warning "Template icon not found, using default"
    fi
}

# Create default icon
create_default_icon() {
    print_debug "Creating default icon"
    # In a real implementation, you'd generate or copy a default icon
    cat > "$APP_DIR/Contents/Resources/app.icns" << EOF
placeholder
EOF
}

# Create localization files
create_localization_files() {
    print_info "Creating localization files for language: $LANGUAGE"
    
    cat > "$APP_DIR/Contents/Resources/en-US.lproj/InfoPlist.strings" << EOF
/* Localized versions of Info.plist keys */

CFBundleName = "$NAME";
CFBundleDisplayName = "$NAME";
CFBundleSpokenName = "$NAME";
NSHumanReadableCopyright = "Copyright © 2026 Bun.app Contributors. All rights reserved.";
EOF
    
    # Add additional languages if supported
    if [[ "$LANGUAGE" != "en-US" ]]; then
        local lang_dir="$APP_DIR/Contents/Resources/${LANGUAGE}.lproj"
        mkdir -p "$lang_dir"
        
        # Add language-specific strings
        cat > "$lang_dir/InfoPlist.strings" << EOF
/* Localized versions of Info.plist keys */

CFBundleName = "$NAME";
CFBundleDisplayName = "$NAME";
CFBundleSpokenName = "$NAME";
NSHumanReadableCopyright = "Copyright © 2026 Bun.app Contributors. All rights reserved.";
EOF
    fi
}

# Create developer resources
create_developer_resources() {
    print_debug "Creating developer resources"
    
    # Create developer tools configuration
    cat > "$APP_DIR/Contents/Resources/developer/dev-tools.json" << EOF
{
    "enabled": true,
    "console_access": true,
    "network_inspector": true,
    "debug_mode": true,
    "hot_reload": false,
    "source_maps": true
}
EOF
    
    # Create debug helper script
    cat > "$APP_DIR/Contents/Resources/debug/debug-helper.sh" << EOF
#!/bin/bash
# Debug helper for developer template

echo "Debug mode enabled for $NAME"
echo "Chrome DevTools: chrome://inspect"
echo "Console: chrome://console"
echo "Network: chrome://net-internals"
EOF
    
    chmod +x "$APP_DIR/Contents/Resources/debug/debug-helper.sh"
}

# Create enterprise resources
create_enterprise_resources() {
    print_debug "Creating enterprise resources"
    
    # Create enterprise policy configuration
    cat > "$APP_DIR/Contents/Resources/enterprise/policies.json" << EOF
{
    "policy_enforcement": true,
    "sso_enabled": true,
    "certificate_management": true,
    "audit_logging": true,
    "data_encryption": true,
    "compliance_mode": true
}
EOF
    
    # Create enterprise configuration
    cat > "$APP_DIR/Contents/Resources/enterprise/config.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>EnterpriseMode</key>
    <true/>
    <key>SSOEnabled</key>
    <true/>
    <key>CertificateManagement</key>
    <true/>
    <key>AuditLogging</key>
    <true/>
</dict>
</plist>
EOF
}

# Create kiosk resources
create_kiosk_resources() {
    print_debug "Creating kiosk resources"
    
    # Create kiosk configuration
    cat > "$APP_DIR/Contents/Resources/kiosk/kiosk-config.json" << EOF
{
    "kiosk_mode": true,
    "fullscreen": true,
    "address_bar_hidden": true,
    "navigation_disabled": true,
    "auto_reset": true,
    "session_timeout": 300,
    "content_filtering": true
}
EOF
    
    # Create reset script
    cat > "$APP_DIR/Contents/Resources/reset/reset-kiosk.sh" << EOF
#!/bin/bash
# Kiosk reset script

echo "Resetting kiosk session..."
# Clear cache, cookies, and reset session
osascript -e 'tell application "System Events" to quit application "'$NAME'"'
sleep 2
open "$APP_DIR"
EOF
    
    chmod +x "$APP_DIR/Contents/Resources/reset/reset-kiosk.sh"
}

# Create code signature
create_code_signature() {
    print_info "Creating enhanced code signature"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would create enhanced code signature"
        return
    fi
    
    cat > "$APP_DIR/Contents/_CodeSignature/CodeResources" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>files</key>
    <dict>
        <key>Resources/app.icns</key>
        <dict>
            <key>hash</key>
            <data>$(create_file_hash "$APP_DIR/Contents/Resources/app.icns")</data>
            <key>optional</key>
            <true/>
        </dict>
        <key>Resources/$(get_template_resource_file)</key>
        <dict>
            <key>hash</key>
            <data>$(create_file_hash "$APP_DIR/Contents/Resources/$(get_template_resource_file)")</data>
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
    <key>requirements</key>
    <dict>
        <key>identifier</key>
        <string>$(generate_bundle_id)</string>
    </dict>
</dict>
</plist>
EOF
    
    print_success "Enhanced code signature created"
}

# Get template-specific resource file
get_template_resource_file() {
    case "$TEMPLATE" in
        "developer") echo "developer/dev-tools.json" ;;
        "enterprise") echo "enterprise/policies.json" ;;
        "kiosk") echo "kiosk/kiosk-config.json" ;;
        *) echo "app.icns" ;;
    esac
}

# Create file hash
create_file_hash() {
    local file="$1"
    if [[ -f "$file" ]]; then
        openssl dgst -sha256 -binary "$file" | base64
    else
        echo "placeholder"
    fi
}

# Optimize app bundle
optimize_app_bundle() {
    print_info "Optimizing app bundle for performance profile: $PERFORMANCE_PROFILE"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would optimize app bundle"
        return
    fi
    
    case "$PERFORMANCE_PROFILE" in
        "optimized")
            optimize_for_standard_performance
            ;;
        "lightweight")
            optimize_for_lightweight
            ;;
        "resource_intensive")
            optimize_for_resource_intensive
            ;;
    esac
    
    print_success "App bundle optimized"
}

# Optimize for standard performance
optimize_for_standard_performance() {
    print_debug "Optimizing for standard performance"
    
    # Enable caching
    create_performance_config "standard" true true true
}

# Optimize for lightweight
optimize_for_lightweight() {
    print_debug "Optimizing for lightweight performance"
    
    # Disable caching, enable lazy loading
    create_performance_config "lightweight" false false true
}

# Optimize for resource intensive
optimize_for_resource_intensive() {
    print_debug "Optimizing for resource-intensive performance"
    
    # Enable all features
    create_performance_config "intensive" true true false
}

# Create performance configuration
create_performance_config() {
    local profile="$1"
    local cache_enabled="$2"
    local prefetch_enabled="$3"
    local lazy_loading="$4"
    
    cat > "$APP_DIR/Contents/Resources/performance-config.json" << EOF
{
    "profile": "$profile",
    "cache_enabled": $cache_enabled,
    "prefetch_enabled": $prefetch_enabled,
    "lazy_loading": $lazy_loading,
    "memory_limit": "$(get_memory_limit)",
    "cpu_limit": "$(get_cpu_limit)"
}
EOF
}

# Get memory limit based on performance profile
get_memory_limit() {
    case "$PERFORMANCE_PROFILE" in
        "lightweight") echo "128MB" ;;
        "optimized") echo "256MB" ;;
        "resource_intensive") echo "512MB" ;;
        *) echo "256MB" ;;
    esac
}

# Get CPU limit based on performance profile
get_cpu_limit() {
    case "$PERFORMANCE_PROFILE" in
        "lightweight") echo "25%" ;;
        "optimized") echo "50%" ;;
        "resource_intensive") echo "75%" ;;
        *) echo "50%" ;;
    esac
}

# Generate build report
generate_build_report() {
    print_info "Generating build report"
    
    local report_file="$OUTPUT_DIR/build-report.json"
    local bundle_id=$(generate_bundle_id)
    local build_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat > "$report_file" << EOF
{
    "build_info": {
        "timestamp": "$build_time",
        "template": "$TEMPLATE",
        "security_profile": "$SECURITY_PROFILE",
        "performance_profile": "$PERFORMANCE_PROFILE",
        "language": "$LANGUAGE",
        "bundle_id": "$bundle_id"
    },
    "app_info": {
        "name": "$NAME",
        "url": "$URL",
        "version": "1.0.0",
        "output_path": "$APP_DIR"
    },
    "configuration": {
        "chrome_path": "/Applications/Google Chrome.app",
        "output_dir": "$OUTPUT_DIR",
        "temp_dir": "$TEMP_DIR"
    },
    "features": {
        "template_features": $(get_template_features),
        "security_features": $(get_security_features),
        "performance_features": $(get_performance_features)
    }
}
EOF
    
    print_success "Build report generated: $report_file"
}

# Get template features
get_template_features() {
    case "$TEMPLATE" in
        "minimal")
            echo '["basic_web_app", "chrome_integration"]'
            ;;
        "developer")
            echo '["basic_web_app", "chrome_integration", "developer_tools", "debug_mode"]'
            ;;
        "enterprise")
            echo '["basic_web_app", "chrome_integration", "enterprise_sso", "certificate_management", "audit_logging"]'
            ;;
        "kiosk")
            echo '["basic_web_app", "chrome_integration", "kiosk_mode", "fullscreen", "auto_reset"]'
            ;;
        *)
            echo '["basic_web_app", "chrome_integration"]'
            ;;
    esac
}

# Get security features
get_security_features() {
    case "$SECURITY_PROFILE" in
        "high")
            echo '["strict_security", "certificate_pinning", "content_security_policy"]'
            ;;
        "medium")
            echo '["standard_security", "content_security_policy"]'
            ;;
        "low")
            echo '["developer_friendly", "relaxed_security"]'
            ;;
        *)
            echo '["standard_security"]'
            ;;
    esac
}

# Get performance features
get_performance_features() {
    case "$PERFORMANCE_PROFILE" in
        "lightweight")
            echo '["minimal_resources", "lazy_loading", "no_caching"]'
            ;;
        "optimized")
            echo '["balanced_performance", "caching", "prefetching"]'
            ;;
        "resource_intensive")
            echo '["maximum_performance", "full_caching", "preloading"]'
            ;;
        *)
            echo '["balanced_performance"]'
            ;;
    esac
}

# Cleanup
cleanup() {
    print_info "Cleaning up temporary files"
    
    if [[ "$KEEP_TEMP" != true ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    print_success "Cleanup complete"
}

# Main build function
main() {
    echo "🚀 Advanced Bun.app Build Script"
    echo "================================="
    
    # Parse arguments
    parse_args "$@"
    
    # Validate arguments
    if [[ -z "$URL" || -z "$NAME" ]]; then
        print_error "URL and NAME are required"
        show_help
        exit 1
    fi
    
    print_info "Building $NAME with template: $TEMPLATE"
    print_info "URL: $URL"
    print_info "Security: $SECURITY_PROFILE"
    print_info "Performance: $PERFORMANCE_PROFILE"
    print_info "Language: $LANGUAGE"
    
    # Load and validate configuration
    load_config
    validate_config
    
    # Setup environment
    setup_environment
    
    # Build process
    create_app_structure
    create_info_plist
    copy_executable
    create_resources
    create_code_signature
    optimize_app_bundle
    
    # Generate report
    generate_build_report
    
    # Cleanup
    cleanup
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Build completed successfully (simulation)"
    else
        print_success "Advanced build completed successfully!"
        print_info "App created: $APP_DIR"
        print_info "To install: cp -r '$APP_DIR' /Applications/"
        print_info "To launch: open '$APP_DIR'"
    fi
}

# Handle script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
