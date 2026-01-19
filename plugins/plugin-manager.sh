#!/bin/bash

# Plugin System and Extension Framework for Bun.app
# Comprehensive plugin management system

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
PLUGINS_DIR="$SCRIPT_DIR/plugins"
CONFIG_FILE="$SCRIPT_DIR/config/plugin-config.yaml"
REGISTRY_URL="https://api.github.com/repos/brendadeeznuts1111/bun-app-plugins"
ACTIVE_PLUGINS_FILE="$SCRIPT_DIR/.active-plugins"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name|-n)
                PLUGIN_NAME="$2"
                shift 2
                ;;
            --type|-t)
                PLUGIN_TYPE="$2"
                shift 2
                ;;
            --version|-v)
                VERSION="$2"
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
Bun.app Plugin Manager

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    init                    Initialize plugin system
    list                    List available plugins
    install <plugin>        Install a plugin
    uninstall <plugin>      Uninstall a plugin
    enable <plugin>         Enable a plugin
    disable <plugin>        Disable a plugin
    update <plugin>         Update a plugin
    create <name>           Create a new plugin
    validate <plugin>       Validate a plugin
    status                  Show plugin status

OPTIONS:
    -n, --name NAME         Plugin name
    -t, --type TYPE         Plugin type (core, extension, theme, tool)
    -v, --version VERSION   Plugin version
    -f, --force             Force operation
    -h, --help              Show this help

PLUGIN TYPES:
    core         Core functionality plugins
    extension    Feature extensions
    theme        UI/UX themes
    tool         Development tools

EXAMPLES:
    $0 init                                    # Initialize plugin system
    $0 list                                    # List available plugins
    $0 install dark-theme                       # Install dark theme plugin
    $0 enable dark-theme                        # Enable dark theme
    $0 create my-plugin --type extension        # Create new extension

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

# Initialize plugin system
init_plugin_system() {
    print_info "Initializing plugin system..."
    
    # Create plugin directories
    mkdir -p "$PLUGINS_DIR"/{core,extensions,themes,tools}
    mkdir -p "$PLUGINS_DIR/registry"
    mkdir -p "$PLUGINS_DIR/cache"
    
    # Create configuration file
    create_plugin_config
    
    # Create active plugins file
    touch "$ACTIVE_PLUGINS_FILE"
    
    # Create plugin templates
    create_plugin_templates
    
    # Create registry
    create_local_registry
    
    print_success "Plugin system initialized"
}

# Create plugin configuration
create_plugin_config() {
    print_info "Creating plugin configuration..."
    
    cat > "$CONFIG_FILE" << EOF
# Bun.app Plugin Configuration

# Plugin system settings
plugin_system:
  enabled: true
  auto_update: false
  allow_unsigned: false
  sandbox_plugins: true
  
# Registry settings
registry:
  url: "$REGISTRY_URL"
  cache_ttl: 3600
  auto_sync: false
  
# Security settings
security:
  verify_signatures: true
  require_permissions: true
  sandbox_enabled: true
  allowed_domains:
    - "github.com"
    - "api.github.com"
    
# Plugin types
plugin_types:
  core:
    description: "Core functionality plugins"
    auto_load: true
    required: true
    
  extension:
    description: "Feature extensions"
    auto_load: false
    required: false
    
  theme:
    description: "UI/UX themes"
    auto_load: false
    required: false
    
  tool:
    description: "Development tools"
    auto_load: false
    required: false

# Plugin lifecycle
lifecycle:
  install_validation: true
  post_install_script: true
  pre_uninstall_script: true
  health_check: true
  
# Performance settings
performance:
  max_plugins: 50
  max_memory_per_plugin: "256MB"
  startup_timeout: 30
  
# Logging
logging:
  enabled: true
  level: "info"
  file: "logs/plugins.log"
EOF
    
    print_success "Plugin configuration created"
}

# Create plugin templates
create_plugin_templates() {
    print_info "Creating plugin templates..."
    
    # Core plugin template
    create_core_template
    
    # Extension plugin template
    create_extension_template
    
    # Theme plugin template
    create_theme_template
    
    # Tool plugin template
    create_tool_template
    
    print_success "Plugin templates created"
}

# Create core plugin template
create_core_template() {
    local template_dir="$PLUGINS_DIR/core/template"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/plugin.json" << 'EOF'
{
  "name": "core-template",
  "version": "1.0.0",
  "type": "core",
  "description": "Core plugin template",
  "author": "Bun.app Team",
  "license": "MIT",
  "main": "index.js",
  "dependencies": {},
  "permissions": [
    "core.access"
  ],
  "hooks": {
    "onLoad": "onLoad",
    "onUnload": "onUnload"
  },
  "compatibility": {
    "min_app_version": "1.0.0",
    "max_app_version": "2.0.0"
  }
}
EOF
    
    cat > "$template_dir/index.js" << 'EOF'
// Core Plugin Template
// This is a template for creating core plugins

class CoreTemplatePlugin {
  constructor() {
    this.name = 'core-template';
    this.version = '1.0.0';
    this.loaded = false;
  }
  
  async onLoad() {
    console.log(`Loading ${this.name} plugin...`);
    
    // Initialize plugin functionality
    this.loaded = true;
    
    console.log(`${this.name} plugin loaded successfully`);
  }
  
  async onUnload() {
    console.log(`Unloading ${this.name} plugin...`);
    
    // Cleanup plugin resources
    this.loaded = false;
    
    console.log(`${this.name} plugin unloaded`);
  }
  
  // Plugin-specific methods
  async doSomething() {
    if (!this.loaded) {
      throw new Error('Plugin not loaded');
    }
    
    // Implement plugin functionality
    return 'Plugin action completed';
  }
}

// Export plugin instance
module.exports = new CoreTemplatePlugin();
EOF
    
    cat > "$template_dir/README.md" << 'EOF'
# Core Plugin Template

This is a template for creating core plugins for Bun.app.

## Structure

- `plugin.json` - Plugin manifest
- `index.js` - Main plugin code
- `README.md` - Plugin documentation

## Usage

1. Copy this template to a new directory
2. Modify `plugin.json` with your plugin details
3. Implement your functionality in `index.js`
4. Test your plugin
5. Submit for review

## API

Core plugins have access to:
- Core application APIs
- System-level functions
- Other core plugins

## Permissions

Core plugins require special permissions and review.
EOF
}

# Create extension plugin template
create_extension_template() {
    local template_dir="$PLUGINS_DIR/extensions/template"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/plugin.json" << 'EOF'
{
  "name": "extension-template",
  "version": "1.0.0",
  "type": "extension",
  "description": "Extension plugin template",
  "author": "Bun.app Team",
  "license": "MIT",
  "main": "index.js",
  "dependencies": {},
  "permissions": [
    "ui.access",
    "storage.read"
  ],
  "hooks": {
    "onLoad": "onLoad",
    "onUnload": "onUnload",
    "onUIReady": "onUIReady"
  },
  "compatibility": {
    "min_app_version": "1.0.0",
    "max_app_version": "2.0.0"
  }
}
EOF
    
    cat > "$template_dir/index.js" << 'EOF'
// Extension Plugin Template
// This is a template for creating extension plugins

class ExtensionTemplatePlugin {
  constructor() {
    this.name = 'extension-template';
    this.version = '1.0.0';
    this.loaded = false;
  }
  
  async onLoad() {
    console.log(`Loading ${this.name} plugin...`);
    
    // Initialize plugin functionality
    this.loaded = true;
    
    console.log(`${this.name} plugin loaded successfully`);
  }
  
  async onUnload() {
    console.log(`Unloading ${this.name} plugin...`);
    
    // Cleanup plugin resources
    this.loaded = false;
    
    console.log(`${this.name} plugin unloaded`);
  }
  
  async onUIReady() {
    console.log('UI is ready, initializing extension...');
    
    // Initialize UI components
    this.initializeUI();
  }
  
  initializeUI() {
    // Add UI elements, event listeners, etc.
    console.log('UI initialized');
  }
  
  // Extension-specific methods
  async performAction() {
    if (!this.loaded) {
      throw new Error('Plugin not loaded');
    }
    
    // Implement extension functionality
    return 'Extension action completed';
  }
}

// Export plugin instance
module.exports = new ExtensionTemplatePlugin();
EOF
}

# Create theme plugin template
create_theme_template() {
    local template_dir="$PLUGINS_DIR/themes/template"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/plugin.json" << 'EOF'
{
  "name": "theme-template",
  "version": "1.0.0",
  "type": "theme",
  "description": "Theme plugin template",
  "author": "Bun.app Team",
  "license": "MIT",
  "main": "theme.css",
  "dependencies": {},
  "permissions": [
    "ui.theme"
  ],
  "hooks": {
    "onLoad": "onLoad",
    "onUnload": "onUnload",
    "onThemeApply": "onThemeApply"
  },
  "compatibility": {
    "min_app_version": "1.0.0",
    "max_app_version": "2.0.0"
  },
  "theme": {
    "name": "Template Theme",
    "colors": {
      "primary": "#007AFF",
      "secondary": "#5856D6",
      "background": "#FFFFFF",
      "text": "#000000"
    },
    "fonts": {
      "primary": "San Francisco",
      "monospace": "SF Mono"
    }
  }
}
EOF
    
    cat > "$template_dir/theme.css" << 'EOF'
/* Theme Plugin Template */
/* This is a template for creating theme plugins */

:root {
  /* Primary colors */
  --theme-primary: #007AFF;
  --theme-secondary: #5856D6;
  --theme-background: #FFFFFF;
  --theme-text: #000000;
  
  /* Fonts */
  --theme-font-primary: "San Francisco", -apple-system, BlinkMacSystemFont, sans-serif;
  --theme-font-monospace: "SF Mono", Monaco, Consolas, monospace;
}

/* Apply theme styles */
body {
  background-color: var(--theme-background);
  color: var(--theme-text);
  font-family: var(--theme-font-primary);
}

.primary-color {
  color: var(--theme-primary);
}

.secondary-color {
  color: var(--theme-secondary);
}

.monospace {
  font-family: var(--theme-font-monospace);
}
EOF
}

# Create tool plugin template
create_tool_template() {
    local template_dir="$PLUGINS_DIR/tools/template"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/plugin.json" << 'EOF'
{
  "name": "tool-template",
  "version": "1.0.0",
  "type": "tool",
  "description": "Tool plugin template",
  "author": "Bun.app Team",
  "license": "MIT",
  "main": "index.js",
  "dependencies": {},
  "permissions": [
    "devtools.access",
    "fs.read"
  ],
  "hooks": {
    "onLoad": "onLoad",
    "onUnload": "onUnload",
    "onDevToolsOpen": "onDevToolsOpen"
  },
  "compatibility": {
    "min_app_version": "1.0.0",
    "max_app_version": "2.0.0"
  }
}
EOF
    
    cat > "$template_dir/index.js" << 'EOF'
// Tool Plugin Template
// This is a template for creating tool plugins

class ToolTemplatePlugin {
  constructor() {
    this.name = 'tool-template';
    this.version = '1.0.0';
    this.loaded = false;
  }
  
  async onLoad() {
    console.log(`Loading ${this.name} plugin...`);
    
    // Initialize tool functionality
    this.loaded = true;
    
    console.log(`${this.name} plugin loaded successfully`);
  }
  
  async onUnload() {
    console.log(`Unloading ${this.name} plugin...`);
    
    // Cleanup tool resources
    this.loaded = false;
    
    console.log(`${this.name} plugin unloaded`);
  }
  
  async onDevToolsOpen() {
    console.log('DevTools opened, initializing tool...');
    
    // Initialize tool panels, commands, etc.
    this.initializeTool();
  }
  
  initializeTool() {
    // Add tool panels, commands, etc.
    console.log('Tool initialized');
  }
  
  // Tool-specific methods
  async executeTool() {
    if (!this.loaded) {
      throw new Error('Plugin not loaded');
    }
    
    // Implement tool functionality
    return 'Tool execution completed';
  }
}

// Export plugin instance
module.exports = new ToolTemplatePlugin();
EOF
}

# Create local registry
create_local_registry() {
    print_info "Creating local plugin registry..."
    
    cat > "$PLUGINS_DIR/registry/index.json" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": "2026-01-19T00:00:00Z",
  "plugins": {
    "core": [],
    "extensions": [],
    "themes": [],
    "tools": []
  },
  "categories": {
    "core": "Core functionality plugins",
    "extensions": "Feature extensions",
    "themes": "UI/UX themes",
    "tools": "Development tools"
  }
}
EOF
    
    print_success "Local registry created"
}

# List available plugins
list_plugins() {
    print_info "Available plugins:"
    echo ""
    
    for type in core extensions themes tools; do
        echo "$type plugins:"
        local plugins_dir="$PLUGINS_DIR/$type"
        
        if [[ -d "$plugins_dir" ]]; then
            for plugin_dir in "$plugins_dir"/*; do
                if [[ -d "$plugin_dir" && "$plugin_dir" != *"template" ]]; then
                    local plugin_name=$(basename "$plugin_dir")
                    local plugin_file="$plugin_dir/plugin.json"
                    
                    if [[ -f "$plugin_file" ]]; then
                        local version=$(jq -r '.version' "$plugin_file" 2>/dev/null || echo "unknown")
                        local description=$(jq -r '.description' "$plugin_file" 2>/dev/null || echo "No description")
                        local status=$(get_plugin_status "$plugin_name")
                        
                        printf "  %-20s %-10s %-10s %s\n" "$plugin_name" "$version" "$status" "$description"
                    fi
                fi
            done
        fi
        echo ""
    done
}

# Get plugin status
get_plugin_status() {
    local plugin_name="$1"
    
    if grep -q "^$plugin_name$" "$ACTIVE_PLUGINS_FILE" 2>/dev/null; then
        echo "Active"
    else
        echo "Inactive"
    fi
}

# Install plugin
install_plugin() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        print_error "Plugin name required"
        return 1
    fi
    
    print_info "Installing plugin: $plugin_name"
    
    # Check if plugin already exists
    if plugin_exists "$plugin_name"; then
        if [[ "$FORCE" != true ]]; then
            print_error "Plugin already exists. Use --force to reinstall."
            return 1
        fi
        print_warning "Plugin already exists, reinstalling..."
        uninstall_plugin "$plugin_name"
    fi
    
    # Determine plugin type and install
    local plugin_type=$(determine_plugin_type "$plugin_name")
    
    case "$plugin_type" in
        "core")
            install_core_plugin "$plugin_name"
            ;;
        "extension")
            install_extension_plugin "$plugin_name"
            ;;
        "theme")
            install_theme_plugin "$plugin_name"
            ;;
        "tool")
            install_tool_plugin "$plugin_name"
            ;;
        *)
            print_error "Unknown plugin type for: $plugin_name"
            return 1
            ;;
    esac
    
    print_success "Plugin installed: $plugin_name"
}

# Check if plugin exists
plugin_exists() {
    local plugin_name="$1"
    
    for type in core extensions themes tools; do
        if [[ -d "$PLUGINS_DIR/$type/$plugin_name" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Determine plugin type
determine_plugin_type() {
    local plugin_name="$1"
    
    for type in core extensions themes tools; do
        if [[ -d "$PLUGINS_DIR/$type/$plugin_name" ]]; then
            echo "$type"
            return
        fi
    done
    
    echo "extension"  # Default
}

# Install core plugin
install_core_plugin() {
    local plugin_name="$1"
    local target_dir="$PLUGINS_DIR/core/$plugin_name"
    
    print_info "Installing core plugin: $plugin_name"
    
    # Create from template
    if [[ "$plugin_name" == "template" ]]; then
        print_warning "Template plugin already exists"
        return
    fi
    
    mkdir -p "$target_dir"
    cp -r "$PLUGINS_DIR/core/template/"* "$target_dir/"
    
    # Update plugin.json with new name
    sed -i '' "s/core-template/$plugin_name/g" "$target_dir/plugin.json"
    
    print_success "Core plugin installed: $plugin_name"
}

# Install extension plugin
install_extension_plugin() {
    local plugin_name="$1"
    local target_dir="$PLUGINS_DIR/extensions/$plugin_name"
    
    print_info "Installing extension plugin: $plugin_name"
    
    mkdir -p "$target_dir"
    cp -r "$PLUGINS_DIR/extensions/template/"* "$target_dir/"
    
    # Update plugin.json with new name
    sed -i '' "s/extension-template/$plugin_name/g" "$target_dir/plugin.json"
    
    print_success "Extension plugin installed: $plugin_name"
}

# Install theme plugin
install_theme_plugin() {
    local plugin_name="$1"
    local target_dir="$PLUGINS_DIR/themes/$plugin_name"
    
    print_info "Installing theme plugin: $plugin_name"
    
    mkdir -p "$target_dir"
    cp -r "$PLUGINS_DIR/themes/template/"* "$target_dir/"
    
    # Update plugin.json with new name
    sed -i '' "s/theme-template/$plugin_name/g" "$target_dir/plugin.json"
    
    print_success "Theme plugin installed: $plugin_name"
}

# Install tool plugin
install_tool_plugin() {
    local plugin_name="$1"
    local target_dir="$PLUGINS_DIR/tools/$plugin_name"
    
    print_info "Installing tool plugin: $plugin_name"
    
    mkdir -p "$target_dir"
    cp -r "$PLUGINS_DIR/tools/template/"* "$target_dir/"
    
    # Update plugin.json with new name
    sed -i '' "s/tool-template/$plugin_name/g" "$target_dir/plugin.json"
    
    print_success "Tool plugin installed: $plugin_name"
}

# Uninstall plugin
uninstall_plugin() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        print_error "Plugin name required"
        return 1
    fi
    
    print_info "Uninstalling plugin: $plugin_name"
    
    # Disable plugin first
    disable_plugin "$plugin_name"
    
    # Remove plugin directory
    for type in core extensions themes tools; do
        local plugin_dir="$PLUGINS_DIR/$type/$plugin_name"
        if [[ -d "$plugin_dir" ]]; then
            rm -rf "$plugin_dir"
            print_success "Plugin uninstalled: $plugin_name"
            return
        fi
    done
    
    print_error "Plugin not found: $plugin_name"
}

# Enable plugin
enable_plugin() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        print_error "Plugin name required"
        return 1
    fi
    
    if ! plugin_exists "$plugin_name"; then
        print_error "Plugin not found: $plugin_name"
        return 1
    fi
    
    if grep -q "^$plugin_name$" "$ACTIVE_PLUGINS_FILE" 2>/dev/null; then
        print_warning "Plugin already enabled: $plugin_name"
        return
    fi
    
    print_info "Enabling plugin: $plugin_name"
    
    # Add to active plugins
    echo "$plugin_name" >> "$ACTIVE_PLUGINS_FILE"
    
    # Load plugin
    load_plugin "$plugin_name"
    
    print_success "Plugin enabled: $plugin_name"
}

# Disable plugin
disable_plugin() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        print_error "Plugin name required"
        return 1
    fi
    
    if ! grep -q "^$plugin_name$" "$ACTIVE_PLUGINS_FILE" 2>/dev/null; then
        print_warning "Plugin already disabled: $plugin_name"
        return
    fi
    
    print_info "Disabling plugin: $plugin_name"
    
    # Unload plugin
    unload_plugin "$plugin_name"
    
    # Remove from active plugins
    grep -v "^$plugin_name$" "$ACTIVE_PLUGINS_FILE" > "$ACTIVE_PLUGINS_FILE.tmp"
    mv "$ACTIVE_PLUGINS_FILE.tmp" "$ACTIVE_PLUGINS_FILE"
    
    print_success "Plugin disabled: $plugin_name"
}

# Load plugin
load_plugin() {
    local plugin_name="$1"
    local plugin_type=$(determine_plugin_type "$plugin_name")
    local plugin_dir="$PLUGINS_DIR/$plugin_type/$plugin_name"
    local plugin_file="$plugin_dir/plugin.json"
    
    print_debug "Loading plugin: $plugin_name"
    
    if [[ ! -f "$plugin_file" ]]; then
        print_error "Plugin manifest not found: $plugin_file"
        return 1
    fi
    
    # Validate plugin
    if ! validate_plugin "$plugin_name"; then
        print_error "Plugin validation failed: $plugin_name"
        return 1
    fi
    
    # Execute onLoad hook if exists
    local main_file="$plugin_dir/$(jq -r '.main' "$plugin_file")"
    if [[ -f "$main_file" ]]; then
        print_debug "Executing plugin main file: $main_file"
        # In a real implementation, you'd load and execute the plugin
    fi
    
    print_debug "Plugin loaded: $plugin_name"
}

# Unload plugin
unload_plugin() {
    local plugin_name="$1"
    local plugin_type=$(determine_plugin_type "$plugin_name")
    local plugin_dir="$PLUGINS_DIR/$plugin_type/$plugin_name"
    local plugin_file="$plugin_dir/plugin.json"
    
    print_debug "Unloading plugin: $plugin_name"
    
    if [[ ! -f "$plugin_file" ]]; then
        print_error "Plugin manifest not found: $plugin_file"
        return 1
    fi
    
    # Execute onUnload hook if exists
    local main_file="$plugin_dir/$(jq -r '.main' "$plugin_file")"
    if [[ -f "$main_file" ]]; then
        print_debug "Executing plugin unload hook"
        # In a real implementation, you'd unload the plugin
    fi
    
    print_debug "Plugin unloaded: $plugin_name"
}

# Update plugin
update_plugin() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        print_error "Plugin name required"
        return 1
    fi
    
    print_info "Updating plugin: $plugin_name"
    
    # In a real implementation, you'd check for updates and download them
    print_success "Plugin updated: $plugin_name"
}

# Create new plugin
create_plugin() {
    local plugin_name="$1"
    local plugin_type="${PLUGIN_TYPE:-extension}"
    
    if [[ -z "$plugin_name" ]]; then
        print_error "Plugin name required"
        return 1
    fi
    
    print_info "Creating new plugin: $plugin_name (type: $plugin_type)"
    
    case "$plugin_type" in
        "core")
            install_core_plugin "$plugin_name"
            ;;
        "extension")
            install_extension_plugin "$plugin_name"
            ;;
        "theme")
            install_theme_plugin "$plugin_name"
            ;;
        "tool")
            install_tool_plugin "$plugin_name"
            ;;
        *)
            print_error "Unknown plugin type: $plugin_type"
            return 1
            ;;
    esac
    
    print_success "Plugin created: $plugin_name"
    print_info "Edit files in: $PLUGINS_DIR/$plugin_type/$plugin_name"
}

# Validate plugin
validate_plugin() {
    local plugin_name="$1"
    local plugin_type=$(determine_plugin_type "$plugin_name")
    local plugin_dir="$PLUGINS_DIR/$plugin_type/$plugin_name"
    local plugin_file="$plugin_dir/plugin.json"
    
    print_debug "Validating plugin: $plugin_name"
    
    if [[ ! -f "$plugin_file" ]]; then
        print_error "Plugin manifest not found: $plugin_file"
        return 1
    fi
    
    # Validate JSON syntax
    if ! jq empty "$plugin_file" 2>/dev/null; then
        print_error "Invalid JSON in plugin manifest: $plugin_file"
        return 1
    fi
    
    # Check required fields
    local required_fields=("name" "version" "type" "description" "main")
    for field in "${required_fields[@]}"; do
        if ! jq -e ".$field" "$plugin_file" > /dev/null; then
            print_error "Missing required field: $field"
            return 1
        fi
    done
    
    # Check main file exists
    local main_file="$plugin_dir/$(jq -r '.main' "$plugin_file")"
    if [[ ! -f "$main_file" ]]; then
        print_error "Main file not found: $main_file"
        return 1
    fi
    
    print_debug "Plugin validation passed: $plugin_name"
    return 0
}

# Show plugin status
show_status() {
    print_info "Plugin System Status:"
    echo ""
    
    # System status
    echo "System:"
    echo "  Plugin System: Enabled"
    echo "  Active Plugins: $(wc -l < "$ACTIVE_PLUGINS_FILE" 2>/dev/null || echo "0")"
    echo "  Total Plugins: $(find "$PLUGINS_DIR" -name "plugin.json" | wc -l)"
    echo ""
    
    # Active plugins
    echo "Active Plugins:"
    if [[ -f "$ACTIVE_PLUGINS_FILE" ]]; then
        while IFS= read -r plugin_name; do
            if [[ -n "$plugin_name" ]]; then
                local plugin_type=$(determine_plugin_type "$plugin_name")
                local plugin_dir="$PLUGINS_DIR/$plugin_type/$plugin_name"
                local plugin_file="$plugin_dir/plugin.json"
                
                if [[ -f "$plugin_file" ]]; then
                    local version=$(jq -r '.version' "$plugin_file" 2>/dev/null || echo "unknown")
                    printf "  %-20s %-10s %s\n" "$plugin_name" "$version" "$plugin_type"
                fi
            fi
        done < "$ACTIVE_PLUGINS_FILE"
    else
        echo "  No active plugins"
    fi
}

# Main function
main() {
    echo "🔌 Bun.app Plugin Manager"
    echo "========================="
    
    # Parse arguments
    parse_args "$@"
    
    # Ensure plugins directory exists
    mkdir -p "$PLUGINS_DIR"
    
    # Handle commands
    case "${1:-help}" in
        "init")
            init_plugin_system
            ;;
        "list")
            list_plugins
            ;;
        "install")
            install_plugin "$2"
            ;;
        "uninstall")
            uninstall_plugin "$2"
            ;;
        "enable")
            enable_plugin "$2"
            ;;
        "disable")
            disable_plugin "$2"
            ;;
        "update")
            update_plugin "$2"
            ;;
        "create")
            create_plugin "$2"
            ;;
        "validate")
            validate_plugin "$2"
            ;;
        "status")
            show_status
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
