#!/bin/bash

# Advanced Authentication Manager for Bun.app
# Supports 2FA, OAuth, SSO, and biometric authentication

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
CONFIG_FILE="$SCRIPT_DIR/config/auth-config.yaml"
USERS_DIR="$SCRIPT_DIR/../users"
SESSIONS_DIR="$USERS_DIR/sessions"
OAUTH_DIR="$SCRIPT_DIR/oauth"
BIOMETRIC_DIR="$SCRIPT_DIR/biometric"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user|-u)
                USER_NAME="$2"
                shift 2
                ;;
            --method|-m)
                AUTH_METHOD="$2"
                shift 2
                ;;
            --provider|-p)
                OAUTH_PROVIDER="$2"
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
Bun.app Advanced Authentication Manager

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    init                    Initialize authentication system
    enable-2fa <user>       Enable two-factor authentication
    disable-2fa <user>      Disable two-factor authentication
    setup-oauth <provider>  Setup OAuth provider
    enable-biometric <user> Enable biometric authentication
    verify <user>           Verify authentication status
    session-status          Show active sessions
    cleanup-sessions        Clean up expired sessions

OPTIONS:
    -u, --user NAME         User name
    -m, --method METHOD     Authentication method
    -p, --provider PROVIDER OAuth provider (google, github, microsoft)
    -f, --force             Force operation
    -h, --help              Show this help

AUTHENTICATION METHODS:
    2fa                     Two-factor authentication (TOTP)
    oauth                   OAuth 2.0 integration
    biometric               Biometric authentication
    sso                     Single sign-on
    certificate             Client certificate authentication

EXAMPLES:
    $0 init                                    # Initialize auth system
    $0 enable-2fa john                         # Enable 2FA for user
    $0 setup-oauth google                      # Setup Google OAuth
    $0 enable-biometric jane                   # Enable biometrics
    $0 verify john                             # Verify auth status

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

# Initialize authentication system
init_auth_system() {
    print_info "Initializing advanced authentication system..."
    
    # Create directories
    mkdir -p "$OAUTH_DIR"
    mkdir -p "$BIOMETRIC_DIR"
    mkdir -p "$SESSIONS_DIR"
    mkdir -p "$SCRIPT_DIR/tokens"
    mkdir -p "$SCRIPT_DIR/certificates"
    
    # Create configuration
    create_auth_config
    
    # Setup 2FA infrastructure
    setup_2fa_infrastructure
    
    # Setup OAuth infrastructure
    setup_oauth_infrastructure
    
    print_success "Authentication system initialized"
}

# Create authentication configuration
create_auth_config() {
    print_info "Creating authentication configuration..."
    
    cat > "$CONFIG_FILE" << 'EOF'
# Bun.app Advanced Authentication Configuration

# Global authentication settings
global:
  enabled: true
  session_timeout: 3600
  max_concurrent_sessions: 5
  require_2fa_for_admin: true
  require_2fa_for_developer: false
  biometric_enabled: true
  certificate_auth_enabled: true

# Two-factor authentication
2fa:
  enabled: true
  issuer: "Bun.app"
  algorithm: "SHA1"
  digits: 6
  period: 30
  window: 1
  backup_codes_count: 10
  qr_code_size: 256

# OAuth providers
oauth:
  enabled: true
  providers:
    google:
      client_id: "your-google-client-id"
      client_secret: "your-google-client-secret"
      redirect_uri: "http://localhost:3000/auth/google/callback"
      scopes: ["openid", "profile", "email"]
      
    github:
      client_id: "your-github-client-id"
      client_secret: "your-github-client-secret"
      redirect_uri: "http://localhost:3000/auth/github/callback"
      scopes: ["user:email"]
      
    microsoft:
      client_id: "your-microsoft-client-id"
      client_secret: "your-microsoft-client-secret"
      redirect_uri: "http://localhost:3000/auth/microsoft/callback"
      scopes: ["openid", "profile", "email"]

# Biometric authentication
biometric:
  enabled: true
  methods:
    - "touch_id"
    - "face_id"
    - "fingerprint"
  timeout: 30
  max_attempts: 3

# Certificate authentication
certificate:
  enabled: true
  ca_cert_path: "certificates/ca.crt"
  client_cert_required: false
  cert_validation: "strict"
  ocsp_checking: true

# Session management
sessions:
  secure_cookies: true
  csrf_protection: true
  rate_limiting: true
  max_login_attempts: 5
  lockout_duration: 900

# Security policies
security:
  password_policy:
    min_length: 12
    require_uppercase: true
    require_lowercase: true
    require_numbers: true
    require_symbols: true
    password_history: 5
    
  ip_whitelist: []
  ip_blacklist: []
  geo_blocking: false
  device_fingerprinting: true

# Audit logging
audit:
  enabled: true
  log_file: "logs/auth.log"
  log_level: "info"
  include_ip: true
  include_user_agent: true
  retention_days: 90
EOF
    
    print_success "Authentication configuration created"
}

# Setup 2FA infrastructure
setup_2fa_infrastructure() {
    print_info "Setting up 2FA infrastructure..."
    
    # Create 2FA directory
    mkdir -p "$SCRIPT_DIR/2fa"
    
    # Check for required tools
    if ! command -v oathtool &> /dev/null; then
        print_warning "oathtool not found. Installing oathtool..."
        if command -v brew &> /dev/null; then
            brew install oath-toolkit
        else
            print_error "Please install oath-toolkit manually"
            return 1
        fi
    fi
    
    # Generate 2FA secret for admin user
    local admin_2fa_file="$SCRIPT_DIR/2fa/admin.secret"
    if [[ ! -f "$admin_2fa_file" ]]; then
        local secret=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        echo "$secret" > "$admin_2fa_file"
        chmod 600 "$admin_2fa_file"
        print_success "2FA secret generated for admin user"
    fi
    
    print_success "2FA infrastructure setup completed"
}

# Setup OAuth infrastructure
setup_oauth_infrastructure() {
    print_info "Setting up OAuth infrastructure..."
    
    # Create OAuth configuration files
    for provider in google github microsoft; do
        local provider_config="$OAUTH_DIR/${provider}.yaml"
        if [[ ! -f "$provider_config" ]]; then
            cat > "$provider_config" << EOF
# OAuth Configuration for $provider

provider: $provider
client_id: ""
client_secret: ""
redirect_uri: "http://localhost:3000/auth/$provider/callback"
scopes: []
enabled: false

# Endpoints
authorization_url: ""
token_url: ""
user_info_url: ""

# Security
state_parameter: true
pkce: true
nonce: true
EOF
        fi
    done
    
    print_success "OAuth infrastructure setup completed"
}

# Enable 2FA for user
enable_2fa() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    print_info "Enabling 2FA for user: $user_name"
    
    # Check if user exists
    local user_dir="$USERS_DIR/$user_name"
    if [[ ! -d "$user_dir" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    # Generate 2FA secret
    local secret=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    local secret_file="$SCRIPT_DIR/2fa/${user_name}.secret"
    
    # Save secret
    echo "$secret" > "$secret_file"
    chmod 600 "$secret_file"
    
    # Generate QR code
    local qr_code_file="$SCRIPT_DIR/2fa/${user_name}.qr.png"
    local issuer="Bun.app"
    local totp_uri="otpauth://totp/${issuer}:${user_name}?secret=${secret}&issuer=${issuer}"
    
    if command -v qrencode &> /dev/null; then
        echo "$totp_uri" | qrencode -o "$qr_code_file" -s 8
        print_success "QR code generated: $qr_code_file"
    else
        print_warning "qrencode not found. Manual setup required."
        echo "TOTP URI: $totp_uri"
    fi
    
    # Generate backup codes
    local backup_codes_file="$SCRIPT_DIR/2fa/${user_name}.backup"
    generate_backup_codes "$backup_codes_file"
    
    # Update user configuration
    local user_config="$user_dir/user.json"
    jq --argjson two_factor '{"enabled": true, "secret_file": "'"$secret_file"'", "backup_codes_file": "'"$backup_codes_file"'", "enabled_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}' '.two_factor = $two_factor' "$user_config" > "$user_config.tmp"
    mv "$user_config.tmp" "$user_config"
    
    print_success "2FA enabled for user: $user_name"
    print_info "Secret saved to: $secret_file"
    print_info "Backup codes saved to: $backup_codes_file"
    
    if [[ -f "$qr_code_file" ]]; then
        print_info "QR code generated: $qr_code_file"
    fi
}

# Generate backup codes
generate_backup_codes() {
    local backup_file="$1"
    
    print_info "Generating backup codes..."
    
    # Generate 10 backup codes
    for i in {1..10}; do
        local code=$(openssl rand -hex 4)
        echo "$code" >> "$backup_file"
    done
    
    chmod 600 "$backup_file"
    print_success "Backup codes generated: $backup_file"
}

# Setup OAuth provider
setup_oauth() {
    local provider="$1"
    
    if [[ -z "$provider" ]]; then
        print_error "OAuth provider required"
        return 1
    fi
    
    if [[ ! "$provider" =~ ^(google|github|microsoft)$ ]]; then
        print_error "Invalid provider: $provider. Use google, github, or microsoft"
        return 1
    fi
    
    print_info "Setting up OAuth provider: $provider"
    
    local provider_config="$OAUTH_DIR/${provider}.yaml"
    
    print_info "Please configure OAuth settings in: $provider_config"
    print_info "You will need to:"
    print_info "1. Create an OAuth app at the provider's developer console"
    print_info "2. Update client_id and client_secret in the config file"
    print_info "3. Set the correct redirect URI"
    print_info "4. Enable the provider when configured"
    
    # Open config file for editing
    if command -v code &> /dev/null; then
        code "$provider_config"
    elif command -v nano &> /dev/null; then
        nano "$provider_config"
    else
        print_info "Config file location: $provider_config"
    fi
}

# Enable biometric authentication
enable_biometric() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    print_info "Enabling biometric authentication for user: $user_name"
    
    # Check if user exists
    local user_dir="$USERS_DIR/$user_name"
    if [[ ! -d "$user_dir" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    # Create biometric configuration
    local biometric_config="$BIOMETRIC_DIR/${user_name}.json"
    
    cat > "$biometric_config" << EOF
{
  "username": "$user_name",
  "biometric_enabled": true,
  "methods": ["touch_id", "face_id"],
  "enrolled_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "device_fingerprint": "$(openssl rand -hex 16)",
  "max_attempts": 3,
  "timeout": 30
}
EOF
    
    chmod 600 "$biometric_config"
    
    # Update user configuration
    local user_config="$user_dir/user.json"
    jq --argjson biometric '{"enabled": true, "config_file": "'"$biometric_config"'", "enrolled_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}' '.biometric = $biometric' "$user_config" > "$user_config.tmp"
    mv "$user_config.tmp" "$user_config"
    
    print_success "Biometric authentication enabled for user: $user_name"
    print_info "Configuration saved to: $biometric_config"
}

# Verify authentication status
verify_auth_status() {
    local user_name="$1"
    
    if [[ -z "$user_name" ]]; then
        print_error "User name required"
        return 1
    fi
    
    print_info "Verifying authentication status for: $user_name"
    
    # Check if user exists
    local user_dir="$USERS_DIR/$user_name"
    if [[ ! -d "$user_dir" ]]; then
        print_error "User not found: $user_name"
        return 1
    fi
    
    # Get user configuration
    local user_config="$user_dir/user.json"
    
    echo ""
    echo "Authentication Status for $user_name:"
    echo "=================================="
    
    # Check 2FA status
    local two_factor_enabled=$(jq -r '.two_factor.enabled // false' "$user_config")
    echo "2FA: $two_factor_enabled"
    
    if [[ "$two_factor_enabled" == "true" ]]; then
        local enabled_at=$(jq -r '.two_factor.enabled_at' "$user_config")
        echo "  Enabled at: $enabled_at"
    fi
    
    # Check biometric status
    local biometric_enabled=$(jq -r '.biometric.enabled // false' "$user_config")
    echo "Biometric: $biometric_enabled"
    
    if [[ "$biometric_enabled" == "true" ]]; then
        local enrolled_at=$(jq -r '.biometric.enrolled_at' "$user_config")
        echo "  Enrolled at: $enrolled_at"
    fi
    
    # Check active sessions
    local active_sessions=0
    for session_file in "$SESSIONS_DIR"/*.json; do
        if [[ -f "$session_file" ]]; then
            local session_user=$(jq -r '.username' "$session_file" 2>/dev/null)
            if [[ "$session_user" == "$user_name" ]]; then
                local active=$(jq -r '.active' "$session_file" 2>/dev/null)
                if [[ "$active" == "true" ]]; then
                    ((active_sessions++))
                fi
            fi
        fi
    done
    
    echo "Active sessions: $active_sessions"
    echo ""
}

# Show session status
show_session_status() {
    print_info "Active authentication sessions:"
    echo ""
    
    printf "%-20s %-20s %-20s %s\n" "Username" "Session ID" "Created" "Status"
    printf "%-20s %-20s %-20s %s\n" "--------" "-----------" "--------" "------"
    
    for session_file in "$SESSIONS_DIR"/*.json; do
        if [[ -f "$session_file" ]]; then
            local username=$(jq -r '.username' "$session_file" 2>/dev/null)
            local session_id=$(jq -r '.session_id' "$session_file" 2>/dev/null | cut -c1-20)
            local created=$(jq -r '.created' "$session_file" 2>/dev/null | cut -d'T' -f1 | cut -c6-)
            local active=$(jq -r '.active' "$session_file" 2>/dev/null)
            local status="Inactive"
            
            if [[ "$active" == "true" ]]; then
                status="Active"
            fi
            
            printf "%-20s %-20s %-20s %s\n" "$username" "$session_id" "$created" "$status"
        fi
    done
}

# Cleanup expired sessions
cleanup_sessions() {
    print_info "Cleaning up expired sessions..."
    
    local cleaned_count=0
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    for session_file in "$SESSIONS_DIR"/*.json; do
        if [[ -f "$session_file" ]]; then
            local last_activity=$(jq -r '.last_activity' "$session_file" 2>/dev/null)
            
            # Check if session is older than 24 hours
            local session_age=$(python3 -c "
from datetime import datetime
dt1 = datetime.strptime('$last_activity', '%Y-%m-%dT%H:%M:%SZ')
dt2 = datetime.strptime('$current_time', '%Y-%m-%dT%H:%M:%SZ')
diff = (dt2 - dt1).total_seconds()
print(int(diff))
" 2>/dev/null || echo "86400")
            
            if [[ $session_age -gt 86400 ]]; then
                rm -f "$session_file"
                ((cleaned_count++))
            fi
        fi
    done
    
    print_success "Cleaned up $cleaned_count expired sessions"
}

# Main function
main() {
    echo "🔐 Bun.app Advanced Authentication Manager"
    echo "=========================================="
    
    # Parse arguments
    parse_args "$@"
    
    # Handle commands
    case "${1:-help}" in
        "init")
            init_auth_system
            ;;
        "enable-2fa")
            enable_2fa "$2"
            ;;
        "disable-2fa")
            print_info "2FA disable functionality not implemented yet"
            ;;
        "setup-oauth")
            setup_oauth "$2"
            ;;
        "enable-biometric")
            enable_biometric "$2"
            ;;
        "verify")
            verify_auth_status "$2"
            ;;
        "session-status")
            show_session_status
            ;;
        "cleanup-sessions")
            cleanup_sessions
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
