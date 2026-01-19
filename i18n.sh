#!/bin/bash

# Internationalization (i18n) Manager for Bun.app
# Multi-language support and localization system

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCALES_DIR="$SCRIPT_DIR/locales"
CONFIG_FILE="$SCRIPT_DIR/config/i18n-config.yaml"
DEFAULT_LANGUAGE="en-US"
SUPPORTED_LANGUAGES=("en-US" "es-ES" "fr-FR" "de-DE" "ja-JP" "zh-CN" "ko-KR" "it-IT" "pt-BR" "ru-RU")

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --language|-l)
                LANGUAGE="$2"
                shift 2
                ;;
            --target|-t)
                TARGET="$2"
                shift 2
                ;;
            --format|-f)
                FORMAT="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
Bun.app Internationalization Manager

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    init                    Initialize i18n system
    translate <lang>        Translate to specific language
    validate <lang>        Validate translation files
    generate <target>       Generate localized resources
    list                   List supported languages
    stats                  Show translation statistics

OPTIONS:
    -l, --language LANG     Target language (default: en-US)
    -t, --target TARGET     Target for generation (app, docs, etc.)
    -f, --format FORMAT     Output format (json, yaml, plist)
    -h, --help              Show this help

SUPPORTED LANGUAGES:
$(printf "    - %s\n" "${SUPPORTED_LANGUAGES[@]}")

EXAMPLES:
    $0 init                                    # Initialize i18n system
    $0 translate es-ES                         # Translate to Spanish
    $0 validate fr-FR                         # Validate French translations
    $0 generate app --language de-DE           # Generate German app resources
    $0 stats                                   # Show translation statistics

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

# Initialize i18n system
init_i18n() {
    print_info "Initializing internationalization system..."
    
    # Create locales directory structure
    mkdir -p "$LOCALES_DIR"
    
    # Create directories for all supported languages
    for lang in "${SUPPORTED_LANGUAGES[@]}"; do
        mkdir -p "$LOCALES_DIR/$lang"
    done
    
    # Create default English strings if they don't exist
    if [[ ! -f "$LOCALES_DIR/$DEFAULT_LANGUAGE/strings.json" ]]; then
        create_default_strings
    fi
    
    # Create configuration file
    create_i18n_config
    
    # Create template for other languages
    create_translation_templates
    
    print_success "i18n system initialized"
}

# Create default English strings
create_default_strings() {
    print_info "Creating default English strings..."
    
    cat > "$LOCALES_DIR/$DEFAULT_LANGUAGE/strings.json" << 'EOF'
{
  "app": {
    "name": "Bun",
    "description": "Chrome web app shortcut for bun.com",
    "version": "1.0.0",
    "copyright": "Copyright © 2026 Bun.app Contributors. All rights reserved."
  },
  "ui": {
    "loading": "Loading...",
    "error": "Error",
    "retry": "Retry",
    "cancel": "Cancel",
    "ok": "OK",
    "yes": "Yes",
    "no": "No",
    "close": "Close",
    "minimize": "Minimize",
    "maximize": "Maximize",
    "fullscreen": "Fullscreen",
    "exit_fullscreen": "Exit Fullscreen",
    "refresh": "Refresh",
    "back": "Back",
    "forward": "Forward",
    "home": "Home",
    "search": "Search",
    "settings": "Settings",
    "about": "About",
    "help": "Help"
  },
  "menu": {
    "file": "File",
    "edit": "Edit",
    "view": "View",
    "history": "History",
    "bookmarks": "Bookmarks",
    "window": "Window",
    "help": "Help"
  },
  "errors": {
    "network_error": "Network Error",
    "connection_failed": "Connection Failed",
    "server_not_found": "Server Not Found",
    "timeout": "Request Timeout",
    "ssl_error": "SSL Error",
    "certificate_error": "Certificate Error",
    "dns_error": "DNS Error",
    "proxy_error": "Proxy Error",
    "authentication_required": "Authentication Required",
    "access_denied": "Access Denied",
    "not_found": "Page Not Found",
    "server_error": "Server Error",
    "service_unavailable": "Service Unavailable"
  },
  "messages": {
    "welcome": "Welcome to Bun",
    "loading_page": "Loading page...",
    "page_loaded": "Page loaded",
    "offline": "You are offline",
    "online": "You are online",
    "syncing": "Syncing...",
    "sync_complete": "Sync complete",
    "update_available": "Update available",
    "update_ready": "Update ready to install",
    "restart_required": "Restart required",
    "settings_saved": "Settings saved",
    "settings_reset": "Settings reset to defaults"
  }
}
EOF
    
    print_success "Default English strings created"
}

# Create i18n configuration
create_i18n_config() {
    print_info "Creating i18n configuration..."
    
    cat > "$CONFIG_FILE" << EOF
# Bun.app Internationalization Configuration

# Default language
default_language: "$DEFAULT_LANGUAGE"

# Supported languages
supported_languages:
$(printf "  - \"%s\"\n" "${SUPPORTED_LANGUAGES[@]}")

# Language display names
language_names:
  "en-US": "English (United States)"
  "es-ES": "Español (España)"
  "fr-FR": "Français (France)"
  "de-DE": "Deutsch (Deutschland)"
  "ja-JP": "日本語 (日本)"
  "zh-CN": "中文 (简体)"
  "ko-KR": "한국어 (대한민국)"
  "it-IT": "Italiano (Italia)"
  "pt-BR": "Português (Brasil)"
  "ru-RU": "Русский (Россия)"

# RTL languages
rtl_languages: []

# Translation settings
translation:
  auto_translate: false
  translation_service: "google"
  api_key: null
  
# Validation settings
validation:
  check_missing_keys: true
  check_empty_values: true
  check_duplicate_keys: true
  validate_json: true

# Generation settings
generation:
  formats:
    - "json"
    - "plist"
    - "yaml"
  
  targets:
    app:
      output_dir: "./Contents/Resources"
      file_pattern: "{lang}.lproj/InfoPlist.strings"
    
    docs:
      output_dir: "./docs/i18n"
      file_pattern: "{lang}.md"
    
    website:
      output_dir: "./website/i18n"
      file_pattern: "{lang}.json"

# Fallback settings
fallback:
  use_default_language: true
  fallback_chain: ["en-US"]
  
# Quality settings
quality:
  min_translation_completeness: 80
  require_review: true
  auto_approve: false
EOF
    
    print_success "i18n configuration created"
}

# Create translation templates
create_translation_templates() {
    print_info "Creating translation templates..."
    
    for lang in "${SUPPORTED_LANGUAGES[@]}"; do
        if [[ "$lang" != "$DEFAULT_LANGUAGE" ]]; then
            # Copy English strings as template
            cp "$LOCALES_DIR/$DEFAULT_LANGUAGE/strings.json" "$LOCALES_DIR/$lang/strings.json"
            
            # Add translation notes
            cat > "$LOCALES_DIR/$lang/README.md" << EOF
# Translation Template for $lang

This is a translation template for the $lang language.

## Translation Guidelines

1. **Keep the JSON structure intact** - Do not modify keys, only translate values
2. **Maintain consistency** - Use consistent terminology throughout
3. **Cultural adaptation** - Adapt translations for cultural context
4. **Testing** - Test translations in the actual application
5. **Review** - Have native speakers review translations

## Translation Status

- **Progress**: 0% (Template only)
- **Reviewer**: Not assigned
- **Last Updated**: $(date)

## Notes

- This file was auto-generated as a template
- Replace English text with appropriate translations
- Remove this comment section when translation is complete
EOF
        fi
    done
    
    print_success "Translation templates created"
}

# Translate to specific language
translate_language() {
    local target_lang="$1"
    
    if [[ -z "$target_lang" ]]; then
        print_error "Language code required"
        return 1
    fi
    
    # Validate language code
    if [[ ! " ${SUPPORTED_LANGUAGES[@]} " =~ " $target_lang " ]]; then
        print_error "Unsupported language: $target_lang"
        print_info "Supported languages: ${SUPPORTED_LANGUAGES[*]}"
        return 1
    fi
    
    print_info "Translating to $target_lang..."
    
    # Check if translation file exists
    local strings_file="$LOCALES_DIR/$target_lang/strings.json"
    if [[ ! -f "$strings_file" ]]; then
        print_error "Translation file not found: $strings_file"
        return 1
    fi
    
    # Show translation progress
    show_translation_progress "$target_lang"
    
    # Open translation file for editing
    print_info "Opening translation file for editing..."
    if command -v code &> /dev/null; then
        code "$strings_file"
    elif command -v vim &> /dev/null; then
        vim "$strings_file"
    else
        open "$strings_file"
    fi
    
    print_success "Translation file opened for editing"
}

# Show translation progress
show_translation_progress() {
    local lang="$1"
    local strings_file="$LOCALES_DIR/$lang/strings.json"
    local default_file="$LOCALES_DIR/$DEFAULT_LANGUAGE/strings.json"
    
    if [[ ! -f "$strings_file" || ! -f "$default_file" ]]; then
        print_warning "Cannot calculate progress: files missing"
        return
    fi
    
    # Count total keys
    local total_keys=$(jq -r 'paths_unsorted(.) | length' "$default_file")
    
    # Count translated keys (non-template values)
    local translated_keys=$(jq -r 'paths_unsorted(.) | map(select(. as $path | getpath($path) | test("Loading...|Error|Retry|Cancel|OK|Yes|No|Close|Minimize|Maximize|Fullscreen|Exit Fullscreen|Refresh|Back|Forward|Home|Search|Settings|About|Help|File|Edit|View|History|Bookmarks|Window") | not)) | length' "$strings_file")
    
    local progress=$(( translated_keys * 100 / total_keys ))
    
    echo "Translation Progress for $lang:"
    echo "  Total keys: $total_keys"
    echo "  Translated: $translated_keys"
    echo "  Progress: $progress%"
    
    if [[ $progress -eq 100 ]]; then
        print_success "Translation complete!"
    elif [[ $progress -gt 80 ]]; then
        print_info "Translation nearly complete"
    elif [[ $progress -gt 50 ]]; then
        print_warning "Translation in progress"
    else
        print_warning "Translation just started"
    fi
}

# Validate translations
validate_translations() {
    local target_lang="$1"
    
    if [[ -z "$target_lang" ]]; then
        print_info "Validating all translations..."
        for lang in "${SUPPORTED_LANGUAGES[@]}"; do
            validate_language "$lang"
        done
    else
        validate_language "$target_lang"
    fi
}

# Validate specific language
validate_language() {
    local lang="$1"
    local strings_file="$LOCALES_DIR/$lang/strings.json"
    local default_file="$LOCALES_DIR/$DEFAULT_LANGUAGE/strings.json"
    
    print_info "Validating $lang translations..."
    
    if [[ ! -f "$strings_file" ]]; then
        print_error "Translation file not found: $strings_file"
        return 1
    fi
    
    local validation_errors=0
    
    # Validate JSON syntax
    if ! jq empty "$strings_file" 2>/dev/null; then
        print_error "Invalid JSON syntax in $strings_file"
        ((validation_errors++))
    fi
    
    # Check for missing keys
    local missing_keys=$(jq -r --arg default "$default_file" --arg current "$strings_file" '
        ($default | from_json | paths_unsorted(.) as $path | $path | join(".")) as $key |
        if ($current | from_json | getpath($key | split(".")) == null) then $key else empty end
    ' <<< "{}")
    
    if [[ -n "$missing_keys" ]]; then
        print_error "Missing keys in $lang:"
        echo "$missing_keys" | while read -r key; do
            echo "  - $key"
        done
        ((validation_errors++))
    fi
    
    # Check for empty values
    local empty_values=$(jq -r --arg current "$strings_file" '
        ($current | from_json | paths_unsorted(.) as $path | $path | join(".")) as $key |
        if ($current | from_json | getpath($key | split(".")) == "" or 
            $current | from_json | getpath($key | split(".")) == "Loading..." or
            $current | from_json | getpath($key | split(".")) == "Error") then $key else empty end
    ' <<< "{}")
    
    if [[ -n "$empty_values" ]]; then
        print_warning "Empty or template values in $lang:"
        echo "$empty_values" | while read -r key; do
            echo "  - $key"
        done
    fi
    
    # Check for extra keys
    local extra_keys=$(jq -r --arg default "$default_file" --arg current "$strings_file" '
        ($current | from_json | paths_unsorted(.) as $path | $path | join(".")) as $key |
        if ($default | from_json | getpath($key | split(".")) == null) then $key else empty end
    ' <<< "{}")
    
    if [[ -n "$extra_keys" ]]; then
        print_warning "Extra keys in $lang:"
        echo "$extra_keys" | while read -r key; do
            echo "  - $key"
        done
    fi
    
    if [[ $validation_errors -eq 0 ]]; then
        print_success "$lang validation passed"
    else
        print_error "$lang validation failed with $validation_errors errors"
    fi
}

# Generate localized resources
generate_localized_resources() {
    local target="$1"
    local lang="${LANGUAGE:-$DEFAULT_LANGUAGE}"
    
    print_info "Generating localized resources for $target ($lang)..."
    
    case "$target" in
        "app")
            generate_app_resources "$lang"
            ;;
        "docs")
            generate_docs_resources "$lang"
            ;;
        "website")
            generate_website_resources "$lang"
            ;;
        *)
            print_error "Unknown target: $target"
            print_info "Available targets: app, docs, website"
            return 1
            ;;
    esac
    
    print_success "Localized resources generated for $target"
}

# Generate app resources
generate_app_resources() {
    local lang="$1"
    local strings_file="$LOCALES_DIR/$lang/strings.json"
    local output_dir="./Contents/Resources/${lang}.lproj"
    
    mkdir -p "$output_dir"
    
    # Generate InfoPlist.strings
    local info_plist="$output_dir/InfoPlist.strings"
    
    # Extract app-related strings
    local app_name=$(jq -r '.app.name' "$strings_file")
    local app_description=$(jq -r '.app.description' "$strings_file")
    local copyright=$(jq -r '.app.copyright' "$strings_file")
    
    cat > "$info_plist" << EOF
/* Localized versions of Info.plist keys */

CFBundleName = "$app_name";
CFBundleDisplayName = "$app_name";
CFBundleSpokenName = "$app_name";
NSHumanReadableCopyright = "$copyright";
EOF
    
    print_success "App resources generated for $lang"
}

# Generate docs resources
generate_docs_resources() {
    local lang="$1"
    local strings_file="$LOCALES_DIR/$lang/strings.json"
    local output_dir="./docs/i18n/$lang"
    
    mkdir -p "$output_dir"
    
    # Generate localized README
    local readme="$output_dir/README.md"
    
    local app_name=$(jq -r '.app.name' "$strings_file")
    local welcome=$(jq -r '.messages.welcome' "$strings_file")
    local loading=$(jq -r '.ui.loading' "$strings_file")
    
    cat > "$readme" << EOF
# $app_name

$welcome

## Installation

$loading...

## Usage

See the main documentation for detailed usage instructions.
EOF
    
    print_success "Documentation resources generated for $lang"
}

# Generate website resources
generate_website_resources() {
    local lang="$1"
    local strings_file="$LOCALES_DIR/$lang/strings.json"
    local output_dir="./website/i18n"
    
    mkdir -p "$output_dir"
    
    # Copy strings as-is for website
    cp "$strings_file" "$output_dir/$lang.json"
    
    print_success "Website resources generated for $lang"
}

# List supported languages
list_languages() {
    print_info "Supported languages:"
    
    for lang in "${SUPPORTED_LANGUAGES[@]}"; do
        local strings_file="$LOCALES_DIR/$lang/strings.json"
        local status="Template"
        
        if [[ -f "$strings_file" ]]; then
            # Check if it's been translated
            if grep -q "Loading..." "$strings_file"; then
                status="In Progress"
            else
                status="Complete"
            fi
        else
            status="Missing"
        fi
        
        echo "  - $lang ($status)"
    done
}

# Show translation statistics
show_stats() {
    print_info "Translation Statistics:"
    echo ""
    
    printf "%-12s %-12s %-12s %-12s\n" "Language" "Total Keys" "Translated" "Progress"
    printf "%-12s %-12s %-12s %-12s\n" "--------" "----------" "----------" "--------"
    
    local default_file="$LOCALES_DIR/$DEFAULT_LANGUAGE/strings.json"
    local total_keys=$(jq -r 'paths_unsorted(.) | length' "$default_file")
    
    for lang in "${SUPPORTED_LANGUAGES[@]}"; do
        local strings_file="$LOCALES_DIR/$lang/strings.json"
        
        if [[ -f "$strings_file" ]]; then
            local translated_keys=$(jq -r 'paths_unsorted(.) | map(select(. as $path | getpath($path) | test("Loading...|Error|Retry|Cancel|OK|Yes|No|Close|Minimize|Maximize|Fullscreen|Exit Fullscreen|Refresh|Back|Forward|Home|Search|Settings|About|Help|File|Edit|View|History|Bookmarks|Window") | not)) | length' "$strings_file")
            local progress=$(( translated_keys * 100 / total_keys ))
            
            printf "%-12s %-12s %-12s %-12s\n" "$lang" "$total_keys" "$translated_keys" "${progress}%"
        else
            printf "%-12s %-12s %-12s %-12s\n" "$lang" "$total_keys" "0" "0%"
        fi
    done
    
    echo ""
    print_info "Overall translation completeness can be improved by completing missing translations."
}

# Main function
main() {
    echo "🌍 Bun.app Internationalization Manager"
    echo "====================================="
    
    # Parse arguments
    parse_args "$@"
    
    # Ensure locales directory exists
    mkdir -p "$LOCALES_DIR"
    
    # Handle commands
    case "${1:-help}" in
        "init")
            init_i18n
            ;;
        "translate")
            translate_language "$2"
            ;;
        "validate")
            validate_translations "$2"
            ;;
        "generate")
            generate_localized_resources "$2"
            ;;
        "list")
            list_languages
            ;;
        "stats")
            show_stats
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
