#!/bin/bash

# Enhanced Plugin System with Marketplace for Bun.app
# Discover, install, and manage plugins from a centralized marketplace

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
CONFIG_FILE="$SCRIPT_DIR/config/marketplace-config.yaml"
MARKETPLACE_DIR="$SCRIPT_DIR/marketplace"
PLUGINS_DIR="$SCRIPT_DIR/plugins"
REGISTRY_DIR="$MARKETPLACE_DIR/registry"
CACHE_DIR="$MARKETPLACE_DIR/cache"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --category|-c)
                CATEGORY="$2"
                shift 2
                ;;
            --search|-s)
                SEARCH_TERM="$2"
                shift 2
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --dev|-d)
                DEV_MODE=true
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
Bun.app Plugin Marketplace

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    init                    Initialize marketplace system
    search [term]           Search for plugins
    install <plugin>        Install a plugin
    uninstall <plugin>      Uninstall a plugin
    update [plugin]         Update plugins
    list                    List installed plugins
    featured                Show featured plugins
    categories              List plugin categories
    publish                 Publish a plugin
    stats                   Show marketplace statistics
    refresh                 Refresh plugin cache

OPTIONS:
    -c, --category CAT      Filter by category
    -s, --search TERM       Search plugins
    -f, --force             Force operation
    -d, --dev               Enable development mode
    -h, --help              Show this help

PLUGIN CATEGORIES:
    - productivity           Productivity tools
    - development           Development utilities
    - security              Security enhancements
    - analytics             Analytics tools
    - ui                    UI/UX improvements
    - integration           Third-party integrations
    - automation            Automation tools
    - entertainment          Entertainment plugins

EXAMPLES:
    $0 init                                    # Initialize marketplace
    $0 search analytics                       # Search analytics plugins
    $0 install dashboard-analytics             # Install a plugin
    $0 list                                    # List installed plugins
    $0 featured                                # Show featured plugins

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
    if [[ "$DEBUG" == true ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Initialize marketplace system
init_marketplace() {
    print_info "Initializing plugin marketplace..."
    
    # Create directories
    mkdir -p "$MARKETPLACE_DIR"/{registry,cache,downloads,temp}
    mkdir -p "$REGISTRY_DIR"/{productivity,development,security,analytics,ui,integration,automation,entertainment}
    mkdir -p "$CACHE_DIR"/{metadata,icons,previews}
    
    # Create configuration
    create_marketplace_config
    
    # Setup plugin registry
    setup_plugin_registry
    
    # Create CLI tools
    create_cli_tools
    
    # Initialize sample plugins
    initialize_sample_plugins
    
    print_success "Plugin marketplace initialized"
}

# Create marketplace configuration
create_marketplace_config() {
    print_info "Creating marketplace configuration..."
    
    cat > "$CONFIG_FILE" << 'EOF'
# Bun.app Plugin Marketplace Configuration

# Global settings
global:
  enabled: true
  auto_update: true
  cache_ttl: 3600
  max_concurrent_downloads: 3
  verify_signatures: true
  dev_mode: false

# Marketplace registry
registry:
  type: "local"
  url: "https://marketplace.bun.app"
  api_version: "v1"
  timeout: 30
  retry_attempts: 3

# Plugin categories
categories:
  productivity:
    name: "Productivity"
    description: "Tools to enhance productivity"
    icon: "productivity"
    
  development:
    name: "Development"
    description: "Development utilities and tools"
    icon: "code"
    
  security:
    name: "Security"
    description: "Security enhancements and tools"
    icon: "shield"
    
  analytics:
    name: "Analytics"
    description: "Analytics and monitoring tools"
    icon: "chart"
    
  ui:
    name: "UI/UX"
    description: "User interface improvements"
    icon: "palette"
    
  integration:
    name: "Integration"
    description: "Third-party service integrations"
    icon: "link"
    
  automation:
    name: "Automation"
    description: "Automation and scripting tools"
    icon: "gear"
    
  entertainment:
    name: "Entertainment"
    description: "Games and entertainment plugins"
    icon: "game"

# Plugin validation
validation:
  required_fields:
    - "name"
    - "version"
    - "description"
    - "author"
    - "category"
    - "license"
    
  file_checks:
    max_size: 104857600  # 100MB
    allowed_types: [".zip", ".tar.gz", ".js", ".sh"]
    scan_malware: true
    
  code_quality:
    lint_check: true
    security_scan: true
    dependency_check: true

# Installation settings
installation:
  auto_dependencies: true
  backup_existing: true
  create_shortcuts: true
  register_system: true
  
  permissions:
    file_system: true
    network: false
    system_access: false
    
  sandbox:
    enabled: true
    isolate_processes: true
    limit_resources: true

# Update management
updates:
  auto_check: true
  check_interval: 86400  # 24 hours
  beta_updates: false
  notify_updates: true
  
  rollback:
    enabled: true
    keep_versions: 3
    auto_rollback: false

# Security settings
security:
  signature_verification: true
  checksum_validation: true
  repository_trust: true
  
  permissions:
    require_approval: false
    allow_unsigned: false
    
  scanning:
    virus_scan: true
    code_analysis: true
    dependency_audit: true

# User preferences
preferences:
  theme: "auto"
  language: "en-US"
  notifications: true
  auto_install_updates: false
  
  display:
    show_beta: false
    show_unverified: false
    sort_by: "popularity"
    
  privacy:
    share_usage_stats: false
    anonymous_analytics: false

# Development settings
development:
  hot_reload: true
  debug_mode: false
  test_plugins: true
  local_registry: true
  
  building:
    minify_code: true
    optimize_assets: true
    generate_docs: true
EOF
    
    print_success "Marketplace configuration created"
}

# Setup plugin registry
setup_plugin_registry() {
    print_info "Setting up plugin registry..."
    
    # Create sample plugin entries
    create_sample_plugins
    
    # Create registry index
    create_registry_index
    
    print_success "Plugin registry setup completed"
}

# Create sample plugins
create_sample_plugins() {
    print_info "Creating sample plugin entries..."
    
    # Analytics Dashboard Plugin
    cat > "$REGISTRY_DIR/analytics/dashboard-analytics.json" << 'EOF'
{
  "id": "dashboard-analytics",
  "name": "Dashboard Analytics",
  "version": "1.2.0",
  "description": "Advanced analytics dashboard with real-time metrics and AI insights",
  "author": "Bun.app Team",
  "category": "analytics",
  "license": "MIT",
  "homepage": "https://github.com/bun-app/dashboard-analytics",
  "repository": "https://github.com/bun-app/dashboard-analytics.git",
  "keywords": ["analytics", "dashboard", "metrics", "ai"],
  "downloads": 15420,
  "rating": 4.8,
  "reviews": 127,
  "created_at": "2024-01-15T00:00:00Z",
  "updated_at": "2024-01-19T10:30:00Z",
  "verified": true,
  "featured": true,
  "beta": false,
  "dependencies": {
    "python": ">=3.8",
    "flask": ">=2.0",
    "pandas": ">=1.3"
  },
  "install": {
    "type": "package",
    "url": "https://github.com/bun-app/dashboard-analytics/releases/download/v1.2.0/dashboard-analytics.zip",
    "checksum": "sha256:abc123def456...",
    "size": 2048576,
    "install_script": "install.sh"
  },
  "screenshots": [
    "https://screenshots.bun.app/dashboard-analytics/main.png",
    "https://screenshots.bun.app/dashboard-analytics/charts.png"
  ],
  "compatibility": {
    "min_version": "1.0.0",
    "platforms": ["macos", "linux", "windows"]
  }
}
EOF
    
    # Security Enhancer Plugin
    cat > "$REGISTRY_DIR/security/security-enhancer.json" << 'EOF'
{
  "id": "security-enhancer",
  "name": "Security Enhancer",
  "version": "2.1.0",
  "description": "Advanced security features including 2FA, encryption, and threat detection",
  "author": "Security Team",
  "category": "security",
  "license": "MIT",
  "homepage": "https://github.com/bun-app/security-enhancer",
  "repository": "https://github.com/bun-app/security-enhancer.git",
  "keywords": ["security", "2fa", "encryption", "threat"],
  "downloads": 12350,
  "rating": 4.9,
  "reviews": 89,
  "created_at": "2024-01-10T00:00:00Z",
  "updated_at": "2024-01-18T15:45:00Z",
  "verified": true,
  "featured": true,
  "beta": false,
  "dependencies": {
    "bash": ">=4.0",
    "openssl": ">=1.1"
  },
  "install": {
    "type": "script",
    "url": "https://github.com/bun-app/security-enhancer/releases/download/v2.1.0/security-enhancer.tar.gz",
    "checksum": "sha256:def456abc789...",
    "size": 1024000,
    "install_script": "install.sh"
  },
  "screenshots": [
    "https://screenshots.bun.app/security-enhancer/main.png"
  ],
  "compatibility": {
    "min_version": "1.0.0",
    "platforms": ["macos", "linux"]
  }
}
EOF
    
    # Productivity Suite Plugin
    cat > "$REGISTRY_DIR/productivity/productivity-suite.json" << 'EOF'
{
  "id": "productivity-suite",
  "name": "Productivity Suite",
  "version": "1.5.2",
  "description": "Comprehensive productivity tools including task management, notes, and time tracking",
  "author": "Productivity Labs",
  "category": "productivity",
  "license": "MIT",
  "homepage": "https://github.com/bun-app/productivity-suite",
  "repository": "https://github.com/bun-app/productivity-suite.git",
  "keywords": ["productivity", "tasks", "notes", "time"],
  "downloads": 18920,
  "rating": 4.7,
  "reviews": 203,
  "created_at": "2024-01-05T00:00:00Z",
  "updated_at": "2024-01-19T08:20:00Z",
  "verified": true,
  "featured": false,
  "beta": false,
  "dependencies": {
    "node": ">=14.0",
    "electron": ">=13.0"
  },
  "install": {
    "type": "package",
    "url": "https://github.com/bun-app/productivity-suite/releases/download/v1.5.2/productivity-suite.zip",
    "checksum": "sha256:789abc123def...",
    "size": 5120000,
    "install_script": "install.sh"
  },
  "screenshots": [
    "https://screenshots.bun.app/productivity-suite/dashboard.png",
    "https://screenshots.bun.app/productivity-suite/tasks.png"
  ],
  "compatibility": {
    "min_version": "1.0.0",
    "platforms": ["macos", "linux", "windows"]
  }
}
EOF
    
    # Development Tools Plugin
    cat > "$REGISTRY_DIR/development/dev-tools.json" << 'EOF'
{
  "id": "dev-tools",
  "name": "Development Tools",
  "version": "3.0.1",
  "description": "Essential development tools including debugger, profiler, and code utilities",
  "author": "DevTools Team",
  "category": "development",
  "license": "MIT",
  "homepage": "https://github.com/bun-app/dev-tools",
  "repository": "https://github.com/bun-app/dev-tools.git",
  "keywords": ["development", "debugger", "profiler", "tools"],
  "downloads": 22150,
  "rating": 4.9,
  "reviews": 156,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-19T12:00:00Z",
  "verified": true,
  "featured": true,
  "beta": false,
  "dependencies": {
    "python": ">=3.8",
    "gcc": ">=8.0"
  },
  "install": {
    "type": "package",
    "url": "https://github.com/bun-app/dev-tools/releases/download/v3.0.1/dev-tools.tar.gz",
    "checksum": "sha256:456def789abc...",
    "size": 3072000,
    "install_script": "install.sh"
  },
  "screenshots": [
    "https://screenshots.bun.app/dev-tools/debugger.png",
    "https://screenshots.bun.app/dev-tools/profiler.png"
  ],
  "compatibility": {
    "min_version": "1.0.0",
    "platforms": ["macos", "linux"]
  }
}
EOF
    
    print_success "Sample plugin entries created"
}

# Create registry index
create_registry_index() {
    print_info "Creating registry index..."
    
    cat > "$REGISTRY_DIR/index.json" << 'EOF'
{
  "version": "1.0.0",
  "generated_at": "2024-01-19T00:00:00Z",
  "total_plugins": 4,
  "categories": {
    "analytics": 1,
    "security": 1,
    "productivity": 1,
    "development": 1
  },
  "featured": [
    "dashboard-analytics",
    "security-enhancer",
    "dev-tools"
  ],
  "recently_updated": [
    "dashboard-analytics",
    "security-enhancer",
    "productivity-suite",
    "dev-tools"
  ],
  "most_downloaded": [
    "dev-tools",
    "productivity-suite",
    "dashboard-analytics",
    "security-enhancer"
  ]
}
EOF
    
    print_success "Registry index created"
}

# Create CLI tools
create_cli_tools() {
    print_info "Creating CLI tools..."
    
    # Create plugin installer
    cat > "$MARKETPLACE_DIR/installer.sh" << 'EOF'
#!/bin/bash

# Plugin Installer for Bun.app Marketplace

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install plugin
install_plugin() {
    local plugin_id="$1"
    local plugin_dir="$2"
    local install_url="$3"
    local checksum="$4"
    
    print_info "Installing plugin: $plugin_id"
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download plugin
    print_info "Downloading plugin..."
    if ! curl -L -o plugin.zip "$install_url"; then
        print_error "Failed to download plugin"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Verify checksum
    if [[ -n "$checksum" ]]; then
        print_info "Verifying checksum..."
        local actual_checksum=$(sha256sum plugin.zip | cut -d' ' -f1)
        if [[ "$actual_checksum" != "${checksum#sha256:}" ]]; then
            print_error "Checksum verification failed"
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    # Extract plugin
    print_info "Extracting plugin..."
    unzip -q plugin.zip
    
    # Run install script if exists
    if [[ -f "install.sh" ]]; then
        print_info "Running install script..."
        chmod +x install.sh
        ./install.sh "$plugin_dir"
    else
        # Copy files directly
        mkdir -p "$plugin_dir"
        cp -r * "$plugin_dir/"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    print_success "Plugin installed successfully"
}

# Main
if [[ $# -lt 4 ]]; then
    print_error "Usage: $0 <plugin_id> <plugin_dir> <install_url> <checksum>"
    exit 1
fi

install_plugin "$@"
EOF
    
    chmod +x "$MARKETPLACE_DIR/installer.sh"
    
    print_success "CLI tools created"
}

# Initialize sample plugins
initialize_sample_plugins() {
    print_info "Initializing sample plugins..."
    
    # Create sample installed plugins directory structure
    mkdir -p "$PLUGINS_DIR"/{installed,available}
    
    print_success "Sample plugins initialized"
}

# Search for plugins
search_plugins() {
    local search_term="$1"
    local category="$2"
    
    print_info "Searching for plugins..."
    
    if [[ -n "$category" ]]; then
        print_info "Category: $category"
    fi
    
    if [[ -n "$search_term" ]]; then
        print_info "Search term: $search_term"
    fi
    
    echo ""
    printf "%-25s %-15s %-10s %-10s %-30s\n" "Plugin Name" "Category" "Version" "Rating" "Description"
    printf "%-25s %-15s %-10s %-10s %-30s\n" "-----------" "--------" "-------" "------" "-----------"
    
    # Search through registry
    for category_dir in "$REGISTRY_DIR"/*; do
        if [[ -d "$category_dir" ]]; then
            local cat_name=$(basename "$category_dir")
            
            # Skip if category filter is set and doesn't match
            if [[ -n "$category" && "$cat_name" != "$category" ]]; then
                continue
            fi
            
            for plugin_file in "$category_dir"/*.json; do
                if [[ -f "$plugin_file" ]]; then
                    local plugin_data=$(cat "$plugin_file")
                    local name=$(echo "$plugin_data" | jq -r '.name')
                    local version=$(echo "$plugin_data" | jq -r '.version')
                    local rating=$(echo "$plugin_data" | jq -r '.rating')
                    local description=$(echo "$plugin_data" | jq -r '.description')
                    local keywords=$(echo "$plugin_data" | jq -r '.keywords[]?' | tr '\n' ' ')
                    
                    # Filter by search term
                    if [[ -n "$search_term" ]]; then
                        if [[ ! "$name $description $keywords" =~ $search_term ]]; then
                            continue
                        fi
                    fi
                    
                    # Truncate description if too long
                    if [[ ${#description} -gt 30 ]]; then
                        description="${description:0:27}..."
                    fi
                    
                    printf "%-25s %-15s %-10s %-10s %-30s\n" "$name" "$cat_name" "$version" "$rating" "$description"
                fi
            done
        fi
    done
    
    echo ""
}

# Install plugin
install_plugin() {
    local plugin_id="$1"
    
    if [[ -z "$plugin_id" ]]; then
        print_error "Plugin ID required"
        return 1
    fi
    
    print_info "Installing plugin: $plugin_id"
    
    # Find plugin in registry
    local plugin_file=""
    for category_dir in "$REGISTRY_DIR"/*; do
        if [[ -d "$category_dir" ]]; then
            local found_file=$(find "$category_dir" -name "${plugin_id}.json" 2>/dev/null)
            if [[ -n "$found_file" ]]; then
                plugin_file="$found_file"
                break
            fi
        fi
    done
    
    if [[ -z "$plugin_file" ]]; then
        print_error "Plugin not found: $plugin_id"
        return 1
    fi
    
    # Parse plugin data
    local plugin_data=$(cat "$plugin_file")
    local name=$(echo "$plugin_data" | jq -r '.name')
    local version=$(echo "$plugin_data" | jq -r '.version')
    local install_url=$(echo "$plugin_data" | jq -r '.install.url')
    local checksum=$(echo "$plugin_data" | jq -r '.install.checksum')
    
    # Check if already installed
    local install_dir="$PLUGINS_DIR/installed/$plugin_id"
    if [[ -d "$install_dir" && "$FORCE" != true ]]; then
        print_warning "Plugin already installed: $name"
        print_info "Use --force to reinstall"
        return 1
    fi
    
    # Install plugin
    local installer="$MARKETPLACE_DIR/installer.sh"
    "$installer" "$plugin_id" "$install_dir" "$install_url" "$checksum"
    
    if [[ $? -eq 0 ]]; then
        print_success "Plugin installed: $name v$version"
        
        # Create metadata file
        local metadata_file="$install_dir/plugin.json"
        echo "$plugin_data" > "$metadata_file"
        
        print_info "Plugin location: $install_dir"
    else
        print_error "Plugin installation failed"
        return 1
    fi
}

# Uninstall plugin
uninstall_plugin() {
    local plugin_id="$1"
    
    if [[ -z "$plugin_id" ]]; then
        print_error "Plugin ID required"
        return 1
    fi
    
    print_info "Uninstalling plugin: $plugin_id"
    
    local install_dir="$PLUGINS_DIR/installed/$plugin_id"
    if [[ ! -d "$install_dir" ]]; then
        print_error "Plugin not installed: $plugin_id"
        return 1
    fi
    
    # Get plugin name
    local name="Unknown"
    if [[ -f "$install_dir/plugin.json" ]]; then
        name=$(jq -r '.name' "$install_dir/plugin.json")
    fi
    
    # Run uninstall script if exists
    if [[ -f "$install_dir/uninstall.sh" ]]; then
        print_info "Running uninstall script..."
        cd "$install_dir"
        chmod +x uninstall.sh
        ./uninstall.sh
    fi
    
    # Remove plugin directory
    rm -rf "$install_dir"
    
    print_success "Plugin uninstalled: $name"
}

# List installed plugins
list_installed() {
    print_info "Installed plugins:"
    echo ""
    
    local installed_dir="$PLUGINS_DIR/installed"
    if [[ ! -d "$installed_dir" ]]; then
        print_info "No plugins installed"
        return
    fi
    
    printf "%-25s %-15s %-10s %-20s\n" "Plugin Name" "Version" "Category" "Installed"
    printf "%-25s %-15s %-10s %-20s\n" "-----------" "--------" "--------" "---------"
    
    for plugin_dir in "$installed_dir"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_id=$(basename "$plugin_dir")
            local metadata_file="$plugin_dir/plugin.json"
            
            if [[ -f "$metadata_file" ]]; then
                local name=$(jq -r '.name' "$metadata_file")
                local version=$(jq -r '.version' "$metadata_file")
                local category=$(jq -r '.category' "$metadata_file")
                local installed=$(stat -f "%Sm" -t "%Y-%m-%d" "$metadata_file" 2>/dev/null || stat -c "%y" "$metadata_file" 2>/dev/null | cut -d' ' -f1)
                
                printf "%-25s %-15s %-10s %-20s\n" "$name" "$version" "$category" "$installed"
            fi
        fi
    done
    
    echo ""
}

# Show featured plugins
show_featured() {
    print_info "Featured plugins:"
    echo ""
    
    local index_file="$REGISTRY_DIR/index.json"
    if [[ ! -f "$index_file" ]]; then
        print_error "Registry index not found"
        return 1
    fi
    
    local featured=$(jq -r '.featured[]?' "$index_file")
    
    printf "%-25s %-15s %-10s %-10s %-30s\n" "Plugin Name" "Category" "Version" "Rating" "Description"
    printf "%-25s %-15s %-10s %-10s %-30s\n" "-----------" "--------" "-------" "------" "-----------"
    
    for plugin_id in $featured; do
        local plugin_file=$(find "$REGISTRY_DIR" -name "${plugin_id}.json" 2>/dev/null)
        if [[ -f "$plugin_file" ]]; then
            local plugin_data=$(cat "$plugin_file")
            local name=$(echo "$plugin_data" | jq -r '.name')
            local version=$(echo "$plugin_data" | jq -r '.version')
            local category=$(echo "$plugin_data" | jq -r '.category')
            local rating=$(echo "$plugin_data" | jq -r '.rating')
            local description=$(echo "$plugin_data" | jq -r '.description')
            
            # Truncate description if too long
            if [[ ${#description} -gt 30 ]]; then
                description="${description:0:27}..."
            fi
            
            printf "%-25s %-15s %-10s %-10s %-30s\n" "$name" "$category" "$version" "$rating" "$description"
        fi
    done
    
    echo ""
}

# List categories
list_categories() {
    print_info "Available categories:"
    echo ""
    
    printf "%-20s %-30s %-10s\n" "Category" "Description" "Plugins"
    printf "%-20s %-30s %-10s\n" "--------" "-----------" "-------"
    
    # Load configuration
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS= read -r category; do
            if [[ "$category" =~ ^[[:space:]]*([a-z]+): ]]; then
                local cat_name="${BASH_REMATCH[1]}"
                local cat_info=$(sed -n "/$cat_name:/,/^[[:space:]]*[a-z]/p" "$CONFIG_FILE" | head -5)
                local cat_desc=$(echo "$cat_info" | grep "description:" | cut -d'"' -f2)
                local cat_icon=$(echo "$cat_info" | grep "icon:" | cut -d'"' -f2)
                
                # Count plugins in category
                local plugin_count=$(find "$REGISTRY_DIR/$cat_name" -name "*.json" 2>/dev/null | wc -l)
                
                printf "%-20s %-30s %-10s\n" "$cat_name" "$cat_desc" "$plugin_count"
            fi
        done < "$CONFIG_FILE"
    fi
    
    echo ""
}

# Show marketplace statistics
show_stats() {
    print_info "Marketplace statistics:"
    echo ""
    
    local total_plugins=0
    local total_downloads=0
    local categories_count=0
    
    # Count plugins and downloads
    for category_dir in "$REGISTRY_DIR"/*; do
        if [[ -d "$category_dir" ]]; then
            ((categories_count++))
            for plugin_file in "$category_dir"/*.json; do
                if [[ -f "$plugin_file" ]]; then
                    ((total_plugins++))
                    local downloads=$(jq -r '.downloads' "$plugin_file" 2>/dev/null || echo "0")
                    total_downloads=$((total_downloads + downloads))
                fi
            done
        fi
    done
    
    echo "Total plugins: $total_plugins"
    echo "Total categories: $categories_count"
    echo "Total downloads: $total_downloads"
    echo ""
    
    # Show top plugins
    print_info "Top downloaded plugins:"
    echo ""
    
    printf "%-25s %-15s %-10s\n" "Plugin Name" "Category" "Downloads"
    printf "%-25s %-15s %-10s\n" "-----------" "--------" "---------"
    
    # Create temporary file for sorting
    local temp_file=$(mktemp)
    
    for category_dir in "$REGISTRY_DIR"/*; do
        if [[ -d "$category_dir" ]]; then
            local cat_name=$(basename "$category_dir")
            for plugin_file in "$category_dir"/*.json; do
                if [[ -f "$plugin_file" ]]; then
                    local name=$(jq -r '.name' "$plugin_file")
                    local downloads=$(jq -r '.downloads' "$plugin_file")
                    echo "$downloads|$name|$cat_name" >> "$temp_file"
                fi
            done
        fi
    done
    
    # Sort and display top 10
    sort -nr "$temp_file" | head -10 | while IFS='|' read -r downloads name category; do
        printf "%-25s %-15s %-10s\n" "$name" "$category" "$downloads"
    done
    
    rm -f "$temp_file"
    echo ""
}

# Refresh plugin cache
refresh_cache() {
    print_info "Refreshing plugin cache..."
    
    # Clear cache
    rm -rf "$CACHE_DIR"/*
    
    # Rebuild index
    create_registry_index
    
    # Download latest metadata (in real implementation)
    print_info "Cache refreshed"
}

# Main function
main() {
    echo "🛍️  Bun.app Plugin Marketplace"
    echo "==============================="
    
    # Parse arguments
    parse_args "$@"
    
    # Handle commands
    case "${1:-help}" in
        "init")
            init_marketplace
            ;;
        "search")
            search_plugins "$2" "$CATEGORY"
            ;;
        "install")
            install_plugin "$2"
            ;;
        "uninstall")
            uninstall_plugin "$2"
            ;;
        "update")
            print_info "Update functionality not implemented yet"
            ;;
        "list")
            list_installed
            ;;
        "featured")
            show_featured
            ;;
        "categories")
            list_categories
            ;;
        "publish")
            print_info "Publish functionality not implemented yet"
            ;;
        "stats")
            show_stats
            ;;
        "refresh")
            refresh_cache
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
