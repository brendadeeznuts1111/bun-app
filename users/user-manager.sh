#!/bin/bash

# User Management System for Bun.app
# Multi-user support with authentication and preferences

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
USERS_DIR="$SCRIPT_DIR/users"
CONFIG_FILE="$SCRIPT_DIR/config/user-config.yaml"
CURRENT_USER_FILE="$SCRIPT_DIR/.current-user"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user|-u)
                USER_NAME="$2"
                shift 2
                ;;
            --email|-e)
                EMAIL="$2"
                shift 2
                ;;
            --role|-r)
                ROLE="$2"
                shift 2
                ;;
            --password|-p)
                PASSWORD="$2"
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
Bun.app User Management System

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    init                    Initialize user system
    create <user>           Create a new user
    delete <user>           Delete a user
    login <user>            Login as user
    logout                  Logout current user
    list                    List all users
    current                 Show current user
    update <user>           Update user information
    permissions <user>      Manage user permissions
    preferences <user>      Manage user preferences

OPTIONS:
    -u, --user NAME         User name
    -e, --email EMAIL       Email address
    -r, --role ROLE         User role
    -p, --password PASS     Password
    -f, --force             Force operation
    -h, --help              Show this help

USER ROLES:
    admin           Full administrative access
    developer       Developer access with debug tools
    power_user      Advanced user access
    standard        Standard user access
    guest           Limited guest access
    readonly        Read-only access

EXAMPLES:
    $0 init                                    # Initialize user system
    $0 create john --email john@example.com    # Create user
    $0 login john                              # Login as user
    $0 list                                    # List all users

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

# Initialize user system
init_user_system() {
    print_info "Initializing user management system..."
    
    # Create directories
    mkdir -p "$USERS_DIR"
    mkdir -p "$USERS_DIR/sessions"
    mkdir -p "$USERS_DIR/preferences"
    mkdir -p "$USERS_DIR/permissions"
    
    # Create configuration
    create_user_config
    
    # Create default admin user
    create_default_admin
    
    # Initialize current user
    echo "guest" > "$CURRENT_USER_FILE"
    
    print_success "User system initialized"
}

# Create user configuration
create_user_config() {
    print_info "Creating user configuration..."
    
    cat > "$CONFIG_FILE" << 'EOF'
# Bun.app User Management Configuration

# User system settings
user_system:
  enabled: true
  authentication_required: false
  session_timeout: 3600
  max_sessions: 10
  auto_logout: true
  
# User roles and permissions
roles:
  admin:
    description: "Full administrative access"
    permissions:
      - "user.create"
      - "user.delete"
      - "user.modify"
      - "profile.create"
      - "profile.delete"
      - "profile.switch"
      - "system.configure"
      - "system.monitor"
      - "security.manage"
      
  developer:
    description: "Developer access with debug tools"
    permissions:
      - "profile.create"
      - "profile.switch"
      - "debug.access"
      - "devtools.access"
      - "logs.view"
      - "system.monitor"
      
  power_user:
    description: "Advanced user access"
    permissions:
      - "profile.create"
      - "profile.switch"
      - "preferences.advanced"
      - "plugins.manage"
      
  standard:
    description: "Standard user access"
    permissions:
      - "profile.switch"
      - "preferences.basic"
      - "bookmarks.manage"
      
  guest:
    description: "Limited guest access"
    permissions:
      - "view.content"
      
  readonly:
    description: "Read-only access"
    permissions:
      - "view.content"

# Security settings
security:
  password_policy:
    min_length: 8
    require_uppercase: true
    require_lowercase: true
    require_numbers: true
    require_symbols: false
  session_management:
    secure_cookies: true
    csrf_protection: true
    rate_limiting: true
  authentication:
    two_factor_enabled: false
    oauth_enabled: false
    ldap_enabled: false

# User preferences
preferences:
  auto_save: true
  sync_enabled: false
  theme_selection: true
  language_selection: true
  
# Session management
sessions:
  max_concurrent: 5
  idle_timeout: 1800
  absolute_timeout: 7200
  cleanup_interval: 300
EOF
    
    print_success "User configuration created"
}

# Create default admin user
create_default_admin() {
    print_info "Creating default admin user..."
    
    local admin_dir="$USERS_DIR/admin"
    
    if [[ -d "$admin_dir" ]]; then
        print_warning "Admin user already exists"
        return
    fi
    
    mkdir -p "$admin_dir"
    
    # Create user configuration
    cat > "$admin_dir/user.json" << 'EOF'
{
  "username": "admin",
  "email": "admin@bun.app",
  "role": "admin",
  "created": "2026-01-19T00:00:00Z",
  "last_login": null,
  "active": true,
  "settings": {
    "theme": "light",
    "language": "en-US",
    "timezone": "UTC"
  },
  "preferences": {
    "auto_login": false,
    "remember_session": true,
    "show_welcome": true
  }
}
EOF
    
    # Create permissions file
    cat > "$USERS_DIR/permissions/admin.json" << 'EOF'
{
  "username": "admin",
  "role": "admin",
  "permissions": [
    "user.create",
    "user.delete",
    "user.modify",
    "profile.create",
    "profile.delete",
    "profile.switch",
    "system.configure",
    "system.monitor",
    "security.manage"
  ],
  "granted": "2026-01-19T00:00:00Z",
  "expires": null
}
EOF
    
    # Create preferences file
    cat > "$USERS_DIR/preferences/admin.json" << 'EOF'
{
  "ui": {
    "theme": "light",
    "language": "en-US",
    "font_size": "medium",
    "sidebar_visible": true
  },
  "behavior": {
    "auto_save": true,
    "auto_login": false,
    "remember_session": true,
    "show_welcome": true
  },
  "privacy": {
    "share_usage_data": false,
    "crash_reports": true,
    "analytics": false
  },
  "advanced": {
    "debug_mode": false,
    "developer_tools": false,
    "experimental_features": false
  }
}
EOF
    
    print_success "Default admin user created"
}

# Create new user
create_user() {
    local user_name="$1"
    local email="${EMAIL:-${user_name}@bun.app}"
    local role="${ROLE:-standard}"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    print_info "Creating user: $user_name"
    
    # Validate user name
    if [[ ! "$user_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Invalid user name. Use only letters, numbers, hyphens, and underscores."
        return 1
    fi
    
    # Check if user already exists
    local user_dir="$USERS_DIR/$user_name"
    if [[ -d "$user_dir" ]]; then
        if [[ "$FORCE" != true ]]; then
            print_error "User already exists. Use --force to recreate."
            return 1
        fi
        print_warning "User already exists, recreating..."
        rm -rf "$user_dir"
    fi
    
    # Validate role
    if [[ ! "$role" =~ ^(admin|developer|power_user|standard|guest|readonly)$ ]]; then
        print_error "Invalid role: $role"
        return 1
    fi
    
    # Create user directory
    mkdir -p "$user_dir"
    
    # Create user configuration
    cat > "$user_dir/user.json" << EOF
{
  "username": "$user_name",
  "email": "$email",
  "role": "$role",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_login": null,
  "active": true,
  "settings": {
    "theme": "light",
    "language": "en-US",
    "timezone": "UTC"
  },
  "preferences": {
    "auto_login": false,
    "remember_session": true,
    "show_welcome": true
  }
}
EOF
    
    # Create permissions file
    create_user_permissions "$user_name" "$role"
    
    # Create preferences file
    create_user_preferences "$user_name"
    
    print_success "User created: $user_name"
    print_info "Role: $role"
    print_info "Email: $email"
}

# Create user permissions
create_user_permissions() {
    local user_name="$1"
    local role="$2"
    
    local permissions_file="$USERS_DIR/permissions/${user_name}.json"
    
    # Get permissions for role
    local permissions=$(get_role_permissions "$role")
    
    cat > "$permissions_file" << EOF
{
  "username": "$user_name",
  "role": "$role",
  "permissions": $permissions,
  "granted": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "expires": null
}
EOF
}

# Get role permissions
get_role_permissions() {
    local role="$1"
    
    case "$role" in
        "admin")
            echo '["user.create", "user.delete", "user.modify", "profile.create", "profile.delete", "profile.switch", "system.configure", "system.monitor", "security.manage"]'
            ;;
        "developer")
            echo '["profile.create", "profile.switch", "debug.access", "devtools.access", "logs.view", "system.monitor"]'
            ;;
        "power_user")
            echo '["profile.create", "profile.switch", "preferences.advanced", "plugins.manage"]'
            ;;
        "standard")
            echo '["profile.switch", "preferences.basic", "bookmarks.manage"]'
            ;;
        "guest")
            echo '["view.content"]'
            ;;
        "readonly")
            echo '["view.content"]'
            ;;
        *)
            echo '[]'
            ;;
    esac
}

# Create user preferences
create_user_preferences() {
    local user_name="$1"
    local preferences_file="$USERS_DIR/preferences/${user_name}.json"
    
    cat > "$preferences_file" << 'EOF'
{
  "ui": {
    "theme": "light",
    "language": "en-US",
    "font_size": "medium",
    "sidebar_visible": true
  },
  "behavior": {
    "auto_save": true,
    "auto_login": false,
    "remember_session": true,
    "show_welcome": true
  },
  "privacy": {
    "share_usage_data": false,
    "crash_reports": true,
    "analytics": false
  },
  "advanced": {
    "debug_mode": false,
    "developer_tools": false,
    "experimental_features": false
  }
}
EOF
}

# Delete user
delete_user() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    print_info "Deleting user: $user_name"
    
    # Cannot delete admin user
    if [[ "$user_name" == "admin" ]]; then
        print_error "Cannot delete admin user"
        return 1
    fi
    
    # Check if user is currently logged in
    local current_user=$(cat "$CURRENT_USER_FILE" 2>/dev/null || echo "guest")
    if [[ "$current_user" == "$user_name" ]]; then
        print_error "Cannot delete currently logged in user"
        return 1
    fi
    
    # Validate user exists
    local user_dir="$USERS_DIR/$user_name"
    if [[ ! -d "$user_dir" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    # Delete user files
    rm -rf "$user_dir"
    rm -f "$USERS_DIR/permissions/${user_name}.json"
    rm -f "$USERS_DIR/preferences/${user_name}.json"
    
    print_success "User deleted: $user_name"
}

# Login as user
login_user() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    print_info "Logging in as: $user_name"
    
    # Validate user exists
    local user_dir="$USERS_DIR/$user_name"
    if [[ ! -d "$user_dir" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    # Check if user is active
    local user_config="$user_dir/user.json"
    local active=$(jq -r '.active' "$user_config")
    if [[ "$active" != "true" ]]; then
        print_error "User is not active: $user_name"
        return 1
    fi
    
    # Create session
    create_user_session "$user_name"
    
    # Update last login
    jq --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '.last_login = $timestamp' "$user_config" > "$user_config.tmp"
    mv "$user_config.tmp" "$user_config"
    
    # Set current user
    echo "$user_name" > "$CURRENT_USER_FILE"
    
    # Apply user preferences
    apply_user_preferences "$user_name"
    
    print_success "Logged in as: $user_name"
}

# Create user session
create_user_session() {
    local user_name="$1"
    local session_id=$(uuidgen 2>/dev/null || date +%s%N)
    local session_file="$USERS_DIR/sessions/${session_id}.json"
    
    cat > "$session_file" << EOF
{
  "session_id": "$session_id",
  "username": "$user_name",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_activity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "active": true
}
EOF
}

# Apply user preferences
apply_user_preferences() {
    local user_name="$1"
    local preferences_file="$USERS_DIR/preferences/${user_name}.json"
    
    if [[ -f "$preferences_file" ]]; then
        print_debug "Applying user preferences for: $user_name"
        
        # Get user preferences
        local theme=$(jq -r '.ui.theme' "$preferences_file")
        local language=$(jq -r '.ui.language' "$preferences_file")
        
        # Apply preferences
        export USER_THEME="$theme"
        export USER_LANGUAGE="$language"
        
        print_debug "Applied preferences: theme=$theme, language=$language"
    fi
}

# Logout current user
logout_user() {
    local current_user=$(cat "$CURRENT_USER_FILE" 2>/dev/null || echo "guest")
    
    if [[ "$current_user" == "guest" ]]; then
        print_warning "No user is currently logged in"
        return
    fi
    
    print_info "Logging out: $current_user"
    
    # Clean up sessions
    cleanup_user_sessions "$current_user"
    
    # Reset current user
    echo "guest" > "$CURRENT_USER_FILE"
    
    # Reset environment
    unset USER_THEME
    unset USER_LANGUAGE
    
    print_success "Logged out: $current_user"
}

# Clean up user sessions
cleanup_user_sessions() {
    local user_name="$1"
    
    for session_file in "$USERS_DIR/sessions"/*.json; do
        if [[ -f "$session_file" ]]; then
            local session_user=$(jq -r '.username' "$session_file")
            if [[ "$session_user" == "$user_name" ]]; then
                rm -f "$session_file"
            fi
        fi
    done
}

# List all users
list_users() {
    print_info "All users:"
    echo ""
    
    local current_user=$(cat "$CURRENT_USER_FILE" 2>/dev/null || echo "guest")
    
    printf "%-20s %-20s %-15s %-20s %s\n" "Username" "Email" "Role" "Created" "Status"
    printf "%-20s %-20s %-15s %-20s %s\n" "--------" "-----" "----" "--------" "------"
    
    for user_dir in "$USERS_DIR"/*; do
        if [[ -d "$user_dir" && "$user_dir" != *"sessions" && "$user_dir" != *"preferences" && "$user_dir" != *"permissions" ]]; then
            local user_name=$(basename "$user_dir")
            local user_config="$user_dir/user.json"
            
            if [[ -f "$user_config" ]]; then
                local email=$(jq -r '.email' "$user_config")
                local role=$(jq -r '.role' "$user_config")
                local created=$(jq -r '.created' "$user_config" | cut -d'T' -f1)
                local active=$(jq -r '.active' "$user_config")
                local status="Inactive"
                
                if [[ "$active" == "true" ]]; then
                    status="Active"
                fi
                
                if [[ "$user_name" == "$current_user" ]]; then
                    status="$status (Current)"
                fi
                
                printf "%-20s %-20s %-15s %-20s %s\n" "$user_name" "$email" "$role" "$created" "$status"
            fi
        fi
    done
}

# Show current user
show_current_user() {
    local current_user=$(cat "$CURRENT_USER_FILE" 2>/dev/null || echo "guest")
    local user_dir="$USERS_DIR/$current_user"
    local user_config="$user_dir/user.json"
    
    print_info "Current User: $current_user"
    
    if [[ -f "$user_config" ]]; then
        echo ""
        echo "User Details:"
        echo "  Username: $(jq -r '.username' "$user_config")"
        echo "  Email: $(jq -r '.email' "$user_config")"
        echo "  Role: $(jq -r '.role' "$user_config")"
        echo "  Created: $(jq -r '.created' "$user_config")"
        echo "  Last Login: $(jq -r '.last_login' "$user_config")"
        echo "  Active: $(jq -r '.active' "$user_config")"
        
        # Show permissions
        local permissions_file="$USERS_DIR/permissions/${current_user}.json"
        if [[ -f "$permissions_file" ]]; then
            echo "  Permissions: $(jq -r '.permissions | length' "$permissions_file") permissions"
        fi
    fi
}

# Update user information
update_user() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    print_info "Updating user: $user_name"
    
    # Validate user exists
    local user_dir="$USERS_DIR/$user_name"
    if [[ ! -d "$user_dir" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    # Update user configuration
    local user_config="$user_dir/user.json"
    
    if [[ -n "$EMAIL" ]]; then
        jq --arg email "$EMAIL" '.email = $email' "$user_config" > "$user_config.tmp"
        mv "$user_config.tmp" "$user_config"
    fi
    
    if [[ -n "$ROLE" ]]; then
        jq --arg role "$ROLE" '.role = $role' "$user_config" > "$user_config.tmp"
        mv "$user_config.tmp" "$user_config"
        # Update permissions
        create_user_permissions "$user_name" "$ROLE"
    fi
    
    print_success "User updated: $user_name"
}

# Manage user permissions
manage_permissions() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    local permissions_file="$USERS_DIR/permissions/${user_name}.json"
    
    if [[ ! -f "$permissions_file" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    print_info "Permissions for $user_name:"
    
    local role=$(jq -r '.role' "$permissions_file")
    echo "  Role: $role"
    echo "  Permissions:"
    
    jq -r '.permissions[]' "$permissions_file" | while read -r permission; do
        echo "    - $permission"
    done
}

# Manage user preferences
manage_preferences() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    local preferences_file="$USERS_DIR/preferences/${user_name}.json"
    
    if [[ ! -f "$preferences_file" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    print_info "Preferences for $user_name:"
    echo ""
    
    echo "UI Settings:"
    echo "  Theme: $(jq -r '.ui.theme' "$preferences_file")"
    echo "  Language: $(jq -r '.ui.language' "$preferences_file")"
    echo "  Font Size: $(jq -r '.ui.font_size' "$preferences_file")"
    
    echo ""
    echo "Behavior Settings:"
    echo "  Auto Save: $(jq -r '.behavior.auto_save' "$preferences_file")"
    echo "  Auto Login: $(jq -r '.behavior.auto_login' "$preferences_file")"
    echo "  Remember Session: $(jq -r '.behavior.remember_session' "$preferences_file")"
}

# Main function
main() {
    echo "👤 Bun.app User Management System"
    echo "==============================="
    
    # Parse arguments
    parse_args "$@"
    
    # Ensure users directory exists
    mkdir -p "$USERS_DIR"
    
    # Handle commands
    case "${1:-help}" in
        "init")
            init_user_system
            ;;
        "create")
            create_user "$2"
            ;;
        "delete")
            delete_user "$2"
            ;;
        "login")
            login_user "$2"
            ;;
        "logout")
            logout_user
            ;;
        "list")
            list_users
            ;;
        "current")
            show_current_user
            ;;
        "update")
            update_user "$2"
            ;;
        "permissions")
            manage_permissions "$2"
            ;;
        "preferences")
            manage_preferences "$2"
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
