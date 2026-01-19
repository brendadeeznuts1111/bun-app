#!/bin/bash

# Multi-Profile Support System for Bun.app
# User profile management and switching

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
PROFILES_DIR="$SCRIPT_DIR/profiles"
USERS_DIR="$SCRIPT_DIR/users"
CONFIG_FILE="$SCRIPT_DIR/config/profile-config.yaml"
ACTIVE_PROFILE_FILE="$SCRIPT_DIR/.active-profile"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile|-p)
                PROFILE_NAME="$2"
                shift 2
                ;;
            --user|-u)
                USER_NAME="$2"
                shift 2
                ;;
            --template|-t)
                TEMPLATE="$2"
                shift 2
                ;;
            --force|-f)
                FORCE=true
                shift
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
Bun.app Multi-Profile Manager

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    init                    Initialize profile system
    create <profile>        Create a new profile
    switch <profile>        Switch to a profile
    delete <profile>        Delete a profile
    list                    List all profiles
    current                 Show current profile
    backup <profile>        Backup a profile
    restore <profile>       Restore a profile
    import <file>           Import profile from file
    export <profile>        Export profile to file

OPTIONS:
    -p, --profile NAME      Profile name
    -u, --user NAME         User name
    -t, --template TEMPLATE Profile template
    -f, --force             Force operation
    -h, --help              Show this help

PROFILE TEMPLATES:
    default         Standard user profile
    developer       Developer profile with debug tools
    enterprise      Enterprise profile with security settings
    kiosk           Kiosk profile with restricted access
    minimal         Minimal profile with basic settings

EXAMPLES:
    $0 init                                    # Initialize profile system
    $0 create my-profile --template developer  # Create developer profile
    $0 switch my-profile                       # Switch to profile
    $0 list                                    # List all profiles

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

# Initialize profile system
init_profile_system() {
    print_info "Initializing multi-profile system..."
    
    # Create directories
    mkdir -p "$PROFILES_DIR"
    mkdir -p "$USERS_DIR"
    mkdir -p "$PROFILES_DIR/backups"
    mkdir -p "$PROFILES_DIR/templates"
    
    # Create configuration
    create_profile_config
    
    # Create profile templates
    create_profile_templates
    
    # Create default profile
    create_default_profile
    
    # Initialize active profile
    echo "default" > "$ACTIVE_PROFILE_FILE"
    
    print_success "Profile system initialized"
}

# Create profile configuration
create_profile_config() {
    print_info "Creating profile configuration..."
    
    cat > "$CONFIG_FILE" << 'EOF'
# Bun.app Profile Configuration

# Profile system settings
profile_system:
  enabled: true
  auto_switch: false
  backup_on_switch: true
  max_profiles: 50
  
# Profile storage
storage:
  profiles_dir: "./profiles"
  users_dir: "./users"
  backups_dir: "./profiles/backups"
  
# Profile templates
templates:
  default:
    description: "Standard user profile"
    settings:
      theme: "light"
      language: "en-US"
      security: "medium"
      performance: "balanced"
      
  developer:
    description: "Developer profile with debug tools"
    settings:
      theme: "dark"
      language: "en-US"
      security: "low"
      performance: "optimized"
      debug_tools: true
      developer_mode: true
      
  enterprise:
    description: "Enterprise profile with security settings"
    settings:
      theme: "light"
      language: "en-US"
      security: "high"
      performance: "secure"
      sso_enabled: true
      audit_logging: true
      
  kiosk:
    description: "Kiosk profile with restricted access"
    settings:
      theme: "minimal"
      language: "en-US"
      security: "high"
      performance: "restricted"
      fullscreen: true
      navigation_locked: true
      
  minimal:
    description: "Minimal profile with basic settings"
    settings:
      theme: "light"
      language: "en-US"
      security: "medium"
      performance: "lightweight"

# Profile settings
settings:
  auto_save: true
  sync_enabled: false
  encryption: false
  compression: true
  
# User management
users:
  max_users_per_profile: 10
  default_permissions: "read"
  guest_access: false
  
# Security
security:
  profile_encryption: false
  password_protection: false
  session_timeout: 3600
  
# Performance
performance:
  profile_switch_timeout: 30
  cleanup_old_profiles: true
  max_profile_age: 2592000  # 30 days
EOF
    
    print_success "Profile configuration created"
}

# Create profile templates
create_profile_templates() {
    print_info "Creating profile templates..."
    
    # Default template
    create_profile_template "default"
    
    # Developer template
    create_profile_template "developer"
    
    # Enterprise template
    create_profile_template "enterprise"
    
    # Kiosk template
    create_profile_template "kiosk"
    
    # Minimal template
    create_profile_template "minimal"
    
    print_success "Profile templates created"
}

# Create individual profile template
create_profile_template() {
    local template_name="$1"
    local template_dir="$PROFILES_DIR/templates/$template_name"
    
    mkdir -p "$template_dir"
    
    # Create profile configuration
    cat > "$template_dir/profile.json" << EOF
{
  "name": "$template_name",
  "version": "1.0.0",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "template": true,
  "settings": {
    "theme": "light",
    "language": "en-US",
    "security": "medium",
    "performance": "balanced"
  },
  "preferences": {
    "auto_launch": true,
    "minimize_on_close": false,
    "show_developer_tools": false,
    "enable_debug_mode": false
  },
  "permissions": {
    "notifications": true,
    "location": false,
    "camera": false,
    "microphone": false
  },
  "plugins": {
    "enabled": [],
    "disabled": []
  },
  "bookmarks": [],
  "history": {
    "enabled": true,
    "clear_on_exit": false
  },
  "security": {
    "safe_browsing": true,
    "block_popups": false,
    "send_do_not_track": false
  }
}
EOF
    
    # Create user configuration
    cat > "$template_dir/users.json" << 'EOF'
{
  "users": [],
  "default_user": null,
  "permissions": {
    "guest_access": false,
    "require_authentication": false
  }
}
EOF
    
    # Create application settings
    cat > "$template_dir/app-settings.json" << 'EOF'
{
  "window": {
    "width": 1200,
    "height": 800,
    "position": "center",
    "fullscreen": false,
    "always_on_top": false
  },
  "browser": {
    "user_agent": "default",
    "javascript_enabled": true,
    "cookies_enabled": true,
    "cache_enabled": true
  },
  "network": {
    "proxy_enabled": false,
    "proxy_server": "",
    "proxy_port": 8080,
    "ssl_verification": true
  },
  "performance": {
    "hardware_acceleration": true,
    "memory_limit": "256MB",
    "cpu_limit": "50%"
  }
}
EOF
}

# Create default profile
create_default_profile() {
    print_info "Creating default profile..."
    
    local profile_dir="$PROFILES_DIR/default"
    
    if [[ -d "$profile_dir" ]]; then
        print_warning "Default profile already exists"
        return
    fi
    
    # Copy template
    cp -r "$PROFILES_DIR/templates/default" "$profile_dir"
    
    # Update profile metadata
    local profile_config="$profile_dir/profile.json"
    jq '.template = false | .created = "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"' "$profile_config" > "$profile_config.tmp"
    mv "$profile_config.tmp" "$profile_config"
    
    print_success "Default profile created"
}

# Create new profile
create_profile() {
    local profile_name="$1"
    local template="${TEMPLATE:-default}"
    
    if [[ -z "$profile_name" ]]; then
        print_error "Profile name required"
        return 1
    fi
    
    print_info "Creating profile: $profile_name (template: $template)"
    
    # Validate profile name
    if [[ ! "$profile_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Invalid profile name. Use only letters, numbers, hyphens, and underscores."
        return 1
    fi
    
    # Check if profile already exists
    local profile_dir="$PROFILES_DIR/$profile_name"
    if [[ -d "$profile_dir" ]]; then
        if [[ "$FORCE" != true ]]; then
            print_error "Profile already exists. Use --force to recreate."
            return 1
        fi
        print_warning "Profile already exists, recreating..."
        rm -rf "$profile_dir"
    fi
    
    # Check if template exists
    local template_dir="$PROFILES_DIR/templates/$template"
    if [[ ! -d "$template_dir" ]]; then
        print_error "Template not found: $template"
        return 1
    fi
    
    # Create profile from template
    cp -r "$template_dir" "$profile_dir"
    
    # Update profile configuration
    local profile_config="$profile_dir/profile.json"
    jq --arg name "$profile_name" '.name = $name | .template = false | .created = "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"' "$profile_config" > "$profile_config.tmp"
    mv "$profile_config.tmp" "$profile_config"
    
    print_success "Profile created: $profile_name"
    print_info "Profile location: $profile_dir"
}

# Switch to profile
switch_profile() {
    local profile_name="$1"
    
    if [[ -z "$profile_name" ]]; then
        print_error "Profile name required"
        return 1
    fi
    
    print_info "Switching to profile: $profile_name"
    
    # Validate profile exists
    local profile_dir="$PROFILES_DIR/$profile_name"
    if [[ ! -d "$profile_dir" ]]; then
        print_error "Profile not found: $profile_name"
        return 1
    fi
    
    # Validate profile configuration
    local profile_config="$profile_dir/profile.json"
    if [[ ! -f "$profile_config" ]]; then
        print_error "Profile configuration not found: $profile_config"
        return 1
    fi
    
    # Backup current profile if requested
    local current_profile=$(cat "$ACTIVE_PROFILE_FILE" 2>/dev/null || echo "default")
    if [[ "$current_profile" != "$profile_name" ]]; then
        backup_profile "$current_profile"
    fi
    
    # Apply profile settings
    apply_profile_settings "$profile_name"
    
    # Update active profile
    echo "$profile_name" > "$ACTIVE_PROFILE_FILE"
    
    print_success "Switched to profile: $profile_name"
}

# Apply profile settings
apply_profile_settings() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"
    local profile_config="$profile_dir/profile.json"
    
    print_debug "Applying profile settings for: $profile_name"
    
    # Get profile settings
    local theme=$(jq -r '.settings.theme' "$profile_config")
    local language=$(jq -r '.settings.language' "$profile_config")
    local security=$(jq -r '.settings.security' "$profile_config")
    
    # Apply theme
    apply_theme "$theme"
    
    # Apply language
    apply_language "$language"
    
    # Apply security settings
    apply_security_settings "$security"
    
    # Apply application settings
    apply_app_settings "$profile_dir"
    
    print_debug "Profile settings applied"
}

# Apply theme
apply_theme() {
    local theme="$1"
    
    print_debug "Applying theme: $theme"
    
    # In a real implementation, you'd apply the theme to the application
    case "$theme" in
        "dark")
            print_debug "Applying dark theme"
            ;;
        "light")
            print_debug "Applying light theme"
            ;;
        "minimal")
            print_debug "Applying minimal theme"
            ;;
        *)
            print_debug "Unknown theme: $theme"
            ;;
    esac
}

# Apply language
apply_language() {
    local language="$1"
    
    print_debug "Applying language: $language"
    
    # In a real implementation, you'd apply the language setting
    export LANG="$language"
}

# Apply security settings
apply_security_settings() {
    local security="$1"
    
    print_debug "Applying security settings: $security"
    
    # In a real implementation, you'd apply security settings
    case "$security" in
        "high")
            print_debug "Applying high security settings"
            ;;
        "medium")
            print_debug "Applying medium security settings"
            ;;
        "low")
            print_debug "Applying low security settings"
            ;;
        *)
            print_debug "Unknown security level: $security"
            ;;
    esac
}

# Apply application settings
apply_app_settings() {
    local profile_dir="$1"
    local app_settings="$profile_dir/app-settings.json"
    
    if [[ -f "$app_settings" ]]; then
        print_debug "Applying application settings"
        
        # In a real implementation, you'd apply the app settings
        local width=$(jq -r '.window.width' "$app_settings")
        local height=$(jq -r '.window.height' "$app_settings")
        
        print_debug "Window size: ${width}x${height}"
    fi
}

# Delete profile
delete_profile() {
    local profile_name="$1"
    
    if [[ -z "$profile_name" ]]; then
        print_error "Profile name required"
        return 1
    fi
    
    print_info "Deleting profile: $profile_name"
    
    # Cannot delete default profile
    if [[ "$profile_name" == "default" ]]; then
        print_error "Cannot delete default profile"
        return 1
    fi
    
    # Check if profile is currently active
    local current_profile=$(cat "$ACTIVE_PROFILE_FILE" 2>/dev/null || echo "default")
    if [[ "$current_profile" == "$profile_name" ]]; then
        print_error "Cannot delete currently active profile"
        return 1
    fi
    
    # Validate profile exists
    local profile_dir="$PROFILES_DIR/$profile_name"
    if [[ ! -d "$profile_dir" ]]; then
        print_error "Profile not found: $profile_name"
        return 1
    fi
    
    # Create backup before deletion
    backup_profile "$profile_name"
    
    # Delete profile
    rm -rf "$profile_dir"
    
    print_success "Profile deleted: $profile_name"
}

# List all profiles
list_profiles() {
    print_info "Available profiles:"
    echo ""
    
    local current_profile=$(cat "$ACTIVE_PROFILE_FILE" 2>/dev/null || echo "default")
    
    printf "%-20s %-15s %-20s %s\n" "Profile" "Template" "Created" "Status"
    printf "%-20s %-15s %-20s %s\n" "--------" "--------" "--------" "------"
    
    for profile_dir in "$PROFILES_DIR"/*; do
        if [[ -d "$profile_dir" ]]; then
            local profile_name=$(basename "$profile_dir")
            local profile_config="$profile_dir/profile.json"
            
            if [[ -f "$profile_config" ]]; then
                local template=$(jq -r '.template // "false"' "$profile_config")
                local created=$(jq -r '.created' "$profile_config" | cut -d'T' -f1)
                local status="Inactive"
                
                if [[ "$profile_name" == "$current_profile" ]]; then
                    status="Active"
                fi
                
                printf "%-20s %-15s %-20s %s\n" "$profile_name" "$template" "$created" "$status"
            fi
        fi
    done
}

# Show current profile
show_current_profile() {
    local current_profile=$(cat "$ACTIVE_PROFILE_FILE" 2>/dev/null || echo "default")
    local profile_dir="$PROFILES_DIR/$current_profile"
    local profile_config="$profile_dir/profile.json"
    
    print_info "Current Profile: $current_profile"
    
    if [[ -f "$profile_config" ]]; then
        echo ""
        echo "Profile Details:"
        echo "  Name: $(jq -r '.name' "$profile_config")"
        echo "  Version: $(jq -r '.version' "$profile_config")"
        echo "  Created: $(jq -r '.created' "$profile_config")"
        echo "  Theme: $(jq -r '.settings.theme' "$profile_config")"
        echo "  Language: $(jq -r '.settings.language' "$profile_config")"
        echo "  Security: $(jq -r '.settings.security' "$profile_config")"
        echo "  Performance: $(jq -r '.settings.performance' "$profile_config')"
    fi
}

# Backup profile
backup_profile() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"
    
    if [[ ! -d "$profile_dir" ]]; then
        print_error "Profile not found: $profile_name"
        return 1
    fi
    
    local backup_dir="$PROFILES_DIR/backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/${profile_name}_backup_${timestamp}.tar.gz"
    
    print_info "Creating backup of profile: $profile_name"
    
    tar -czf "$backup_file" -C "$PROFILES_DIR" "$profile_name"
    
    print_success "Backup created: $backup_file"
}

# Restore profile
restore_profile() {
    local backup_file="$1"
    
    if [[ -z "$backup_file" ]]; then
        print_error "Backup file required"
        return 1
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        print_error "Backup file not found: $backup_file"
        return 1
    fi
    
    print_info "Restoring profile from: $backup_file"
    
    # Extract backup
    tar -xzf "$backup_file" -C "$PROFILES_DIR"
    
    print_success "Profile restored from backup"
}

# Import profile
import_profile() {
    local import_file="$1"
    
    if [[ -z "$import_file" ]]; then
        print_error "Import file required"
        return 1
    fi
    
    if [[ ! -f "$import_file" ]]; then
        print_error "Import file not found: $import_file"
        return 1
    fi
    
    print_info "Importing profile from: $import_file"
    
    # Extract import
    tar -xzf "$import_file" -C "$PROFILES_DIR"
    
    print_success "Profile imported successfully"
}

# Export profile
export_profile() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"
    
    if [[ -z "$profile_name" ]]; then
        print_error "Profile name required"
        return 1
    fi
    
    if [[ ! -d "$profile_dir" ]]; then
        print_error "Profile not found: $profile_name"
        return 1
    fi
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local export_file="${profile_name}_export_${timestamp}.tar.gz"
    
    print_info "Exporting profile: $profile_name"
    
    tar -czf "$export_file" -C "$PROFILES_DIR" "$profile_name"
    
    print_success "Profile exported: $export_file"
}

# Main function
main() {
    echo "👥 Bun.app Multi-Profile Manager"
    echo "==============================="
    
    # Parse arguments
    parse_args "$@"
    
    # Ensure profiles directory exists
    mkdir -p "$PROFILES_DIR"
    
    # Handle commands
    case "${1:-help}" in
        "init")
            init_profile_system
            ;;
        "create")
            create_profile "$2"
            ;;
        "switch")
            switch_profile "$2"
            ;;
        "delete")
            delete_profile "$2"
            ;;
        "list")
            list_profiles
            ;;
        "current")
            show_current_profile
            ;;
        "backup")
            backup_profile "$2"
            ;;
        "restore")
            restore_profile "$2"
            ;;
        "import")
            import_profile "$2"
            ;;
        "export")
            export_profile "$2"
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
