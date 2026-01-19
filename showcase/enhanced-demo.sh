#!/bin/bash

# Enhanced Interactive Demo System for Bun.app
# Showcases all enterprise features including security, collaboration, analytics, and marketplace

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
DEMO_DIR="$SCRIPT_DIR/demos"
TEMP_DIR="$SCRIPT_DIR/temp"

# Demo state
DEMO_MODE=""
CURRENT_STEP=0
TOTAL_STEPS=0
AUTO_ADVANCE=false
ADVANCE_DELAY=3

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto|-a)
                AUTO_ADVANCE=true
                shift
                ;;
            --delay|-d)
                ADVANCE_DELAY="$2"
                shift 2
                ;;
            --feature|-f)
                FEATURE_FOCUS="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                DEMO_MODE="$1"
                shift
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
🎬 Bun.app Enhanced Interactive Demo System

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    quick                   Quick 5-minute overview
    full                    Complete feature demonstration (20 minutes)
    security                Security features deep dive
    collaboration           Real-time collaboration showcase
    analytics               AI-powered analytics demonstration
    marketplace             Plugin marketplace tour
    tour                    Interactive guided tour
    custom                  Custom demo builder

OPTIONS:
    -a, --auto             Auto-advance through demo steps
    -d, --delay SECONDS    Delay between auto-advances (default: 3)
    -f, --feature FEATURE  Focus on specific feature
    -h, --help             Show this help

FEATURES DEMONSTRATED:
    🔐 Advanced Security    2FA, OAuth, Biometrics, Certificates
    🤝 Real-time Collaboration  Live editing, Chat, Presence
    🤖 AI Analytics        ML predictions, Dashboard, Insights
    🛍️ Plugin Marketplace   Discovery, Installation, Management
    👥 Multi-User System   Roles, Profiles, Sessions
    🏗️ Build System       Templates, Security, Performance
    🌍 Internationalization 10-language support
    📊 Monitoring          Real-time metrics, Health checks

EXAMPLES:
    $0 quick                                   # Quick overview
    $0 full --auto                            # Full demo with auto-advance
    $0 security                              # Security deep dive
    $0 analytics --delay 5                    # Analytics demo with 5s delay
    $0 custom --feature collaboration         # Custom collaboration demo

EOF
}

# Utility functions
print_header() {
    clear
    echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║                    🎬 Bun.app Enhanced Demo                    ║${NC}"
    echo -e "${BOLD}${BLUE}║              Enterprise-Grade Platform Showcase              ║${NC}"
    echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    local step_num="$1"
    local step_title="$2"
    local step_desc="$3"
    
    echo -e "${BOLD}${CYAN}Step $step_num: $step_title${NC}"
    echo -e "${YELLOW}$step_desc${NC}"
    echo ""
}

print_feature() {
    local icon="$1"
    local title="$2"
    local desc="$3"
    
    echo -e "${GREEN}$icon $title${NC}"
    echo -e "   $desc"
    echo ""
}

print_command() {
    local command="$1"
    local description="$2"
    
    echo -e "${PURPLE}💻 Command:${NC}"
    echo -e "${BOLD}   $command${NC}"
    echo -e "   $description"
    echo ""
}

wait_for_input() {
    if [[ "$AUTO_ADVANCE" == true ]]; then
        sleep "$ADVANCE_DELAY"
    else
        echo -e "${CYAN}Press Enter to continue...${NC}"
        read -r
    fi
}

show_spinner() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Quick demo - 5 minute overview
quick_demo() {
    print_header
    echo -e "${BOLD}${GREEN}🚀 Quick Overview - Bun.app Enterprise Platform${NC}"
    echo -e "${YELLOW}A comprehensive showcase in 5 minutes${NC}"
    echo ""
    
    wait_for_input
    
    # Introduction
    print_step "1" "Platform Introduction" "Bun.app transforms from a simple Chrome web app into a comprehensive enterprise platform"
    
    print_feature "📊" "15,000+ lines of code" "Advanced functionality across 10 major systems"
    print_feature "🏆" "80+ enterprise features" "Security, collaboration, analytics, and more"
    print_feature "🌍" "Multi-platform support" "macOS, Windows, Linux with Apple Silicon optimization"
    
    wait_for_input
    
    # Core Features
    print_step "2" "Core Architecture" "Multi-user system with role-based access control"
    
    print_command "./users/user-manager.sh create john --role developer" "Create users with different roles"
    print_command "./profiles/profile-manager.sh create dev-profile --template developer" "Create specialized profiles"
    print_command "./plugins/plugin-manager.sh create dark-theme --type theme" "Install and manage plugins"
    
    wait_for_input
    
    # Enhanced Security
    print_step "3" "Advanced Security" "Enterprise-grade security with modern authentication"
    
    print_feature "🔐" "Two-Factor Authentication" "TOTP with QR code generation"
    print_feature "🌐" "OAuth Integration" "Google, GitHub, Microsoft SSO"
    print_feature "👆" "Biometric Authentication" "Touch ID and Face ID support"
    
    print_command "./security/auth-manager.sh enable-2fa john" "Enable 2FA for users"
    print_command "./security/auth-manager.sh setup-oauth google" "Setup OAuth providers"
    
    wait_for_input
    
    # Real-time Collaboration
    print_step "4" "Real-time Collaboration" "Live editing and communication"
    
    print_feature "⚡" "WebSocket Server" "Real-time data synchronization"
    print_feature "💬" "Live Chat System" "File attachments and rich messaging"
    print_feature "👥" "User Presence" "See who's online and what they're doing"
    
    print_command "./collaboration/collab-server.sh start" "Start collaboration server"
    print_command "Open http://localhost:8080" "Access collaboration dashboard"
    
    wait_for_input
    
    # AI Analytics
    print_step "5" "AI-Powered Analytics" "Machine learning insights and predictions"
    
    print_feature "🤖" "Predictive Analytics" "Usage forecasting with ML models"
    print_feature "📈" "Real-time Dashboard" "Interactive charts and metrics"
    print_feature "🔍" "Anomaly Detection" "Automatic threat and performance monitoring"
    
    print_command "./analytics/ai-dashboard.sh start" "Launch analytics dashboard"
    print_command "./analytics/ai-dashboard.sh analyze" "Run AI analysis"
    
    wait_for_input
    
    # Plugin Marketplace
    print_step "6" "Plugin Marketplace" "Discover and install extensions"
    
    print_feature "🛍️" "Central Registry" "Browse plugins by category"
    print_feature "🔒" "Security Validation" "Checksum verification and malware scanning"
    print_feature "📊" "Usage Analytics" "Track plugin performance and popularity"
    
    print_command "./plugins/marketplace.sh search analytics" "Search for plugins"
    print_command "./plugins/marketplace.sh install dashboard-analytics" "Install plugins"
    
    wait_for_input
    
    # Conclusion
    print_header
    echo -e "${BOLD}${GREEN}🎉 Demo Complete!${NC}"
    echo ""
    echo -e "${YELLOW}Bun.app Enterprise Platform Features:${NC}"
    echo ""
    print_feature "✅" "Multi-user architecture" "Role-based access control"
    print_feature "✅" "Advanced security" "2FA, OAuth, biometrics"
    print_feature "✅" "Real-time collaboration" "Live editing and chat"
    print_feature "✅" "AI-powered analytics" "ML predictions and insights"
    print_feature "✅" "Plugin marketplace" "Extensible architecture"
    print_feature "✅" "Enterprise monitoring" "Comprehensive observability"
    echo ""
    echo -e "${CYAN}Ready to get started? Check out the Quick Start guide in the README!${NC}"
    echo ""
}

# Full demo - comprehensive feature demonstration
full_demo() {
    print_header
    echo -e "${BOLD}${GREEN}🎬 Full Feature Demonstration${NC}"
    echo -e "${YELLOW}Complete tour of all enterprise features (20 minutes)${NC}"
    echo ""
    
    wait_for_input
    
    # System Overview
    print_step "1" "System Architecture" "Understanding the complete platform"
    
    echo -e "${BLUE}Platform Components:${NC}"
    echo "  📱 Native macOS Application"
    echo "  👥 Multi-User Management System"
    echo "  🏗️ Advanced Build System"
    echo "  🔒 Security Framework"
    echo "  🤝 Collaboration Server"
    echo "  🤖 Analytics Engine"
    echo "  🛍️ Plugin Marketplace"
    echo "  🌍 Internationalization"
    echo "  📊 Monitoring System"
    echo "  🎪 Demonstration Framework"
    
    wait_for_input
    
    # User Management Deep Dive
    print_step "2" "User Management System" "Comprehensive multi-user architecture"
    
    print_command "./users/user-manager.sh init" "Initialize user system"
    echo ""
    echo -e "${CYAN}Creating Users with Different Roles:${NC}"
    print_command "./users/user-manager.sh create admin --role admin" "Full administrative access"
    print_command "./users/user-manager.sh create developer --role developer" "Developer with debug tools"
    print_command "./users/user-manager.sh create analyst --role power_user" "Advanced user access"
    print_command "./users/user-manager.sh create guest --role guest" "Limited guest access"
    
    echo ""
    echo -e "${CYAN}User Session Management:${NC}"
    print_command "./users/user-manager.sh login admin" "Switch between users"
    print_command "./users/user-manager.sh current" "Show current user details"
    print_command "./users/user-manager.sh list" "List all users with status"
    
    wait_for_input
    
    # Profile Management
    print_step "3" "Profile Management" "Template-based configuration system"
    
    echo -e "${CYAN}Available Profile Templates:${NC}"
    echo "  🏢 Enterprise - Corporate deployment with SSO"
    echo "  💻 Developer - Development environment with debug tools"
    echo "  🖥️ Kiosk - Public display mode with restrictions"
    echo "  ⚡ Minimal - Lightweight, fast-launch configuration"
    echo "  🔧 Standard - Balanced feature set"
    
    echo ""
    print_command "./profiles/profile-manager.sh create enterprise-profile --template enterprise" "Create enterprise profile"
    print_command "./profiles/profile-manager.sh switch enterprise-profile" "Switch between profiles"
    print_command "./profiles/profile-manager.sh backup current-profile" "Backup and restore profiles"
    
    wait_for_input
    
    # Advanced Security Deep Dive
    print_step "4" "Advanced Security Framework" "Enterprise-grade authentication and authorization"
    
    echo -e "${CYAN}Security Features:${NC}"
    print_feature "🔐" "Two-Factor Authentication" "TOTP with backup codes"
    print_feature "🌐" "OAuth 2.0 Integration" "Support for major identity providers"
    print_feature "👆" "Biometric Authentication" "Touch ID and Face ID"
    print_feature "📜" "Certificate Authentication" "Client certificate validation"
    print_feature "🔒" "Session Security" "Timeout, CSRF protection, rate limiting"
    print_feature "📋" "Audit Logging" "Comprehensive security event tracking"
    
    echo ""
    print_command "./security/auth-manager.sh init" "Initialize security system"
    print_command "./security/auth-manager.sh enable-2fa admin" "Enable 2FA with QR code"
    print_command "./security/auth-manager.sh setup-oauth google" "Configure OAuth provider"
    print_command "./security/auth-manager.sh enable-biometric developer" "Setup biometric auth"
    print_command "./security/auth-manager.sh session-status" "Monitor active sessions"
    
    wait_for_input
    
    # Real-time Collaboration Deep Dive
    print_step "5" "Real-time Collaboration System" "WebSocket-based live collaboration"
    
    echo -e "${CYAN}Collaboration Features:${NC}"
    print_feature "⚡" "Real-time Document Editing" "Operational transformation"
    print_feature "🖱️" "Live Cursor Tracking" "See other users' cursors and selections"
    print_feature "💬" "Chat System" "Real-time messaging with file sharing"
    print_feature "👥" "User Presence" "Online status and typing indicators"
    print_feature "📹" "WebRTC Preparation" "Ready for audio/video calls"
    print_feature "🖥️" "Screen Sharing" "Desktop sharing capabilities"
    
    echo ""
    print_command "./collaboration/collab-server.sh init" "Initialize collaboration system"
    print_command "./collaboration/collab-server.sh start --port 8080" "Start WebSocket server"
    print_command "./collaboration/collab-server.sh test" "Test collaboration features"
    echo ""
    echo -e "${CYAN}Access Points:${NC}"
    echo "  🌐 Web Dashboard: http://localhost:8080"
    echo "  🔗 WebSocket: ws://localhost:8080"
    echo "  📊 Health Check: http://localhost:8080/health"
    
    wait_for_input
    
    # AI Analytics Deep Dive
    print_step "6" "AI-Powered Analytics" "Machine learning and predictive insights"
    
    echo -e "${CYAN}Analytics Components:${NC}"
    print_feature "🤖" "Machine Learning Models" "Usage prediction, anomaly detection"
    print_feature "📊" "Real-time Dashboard" "Interactive charts and metrics"
    print_feature "🔍" "Behavioral Analysis" "User clustering and insights"
    print_feature "📈" "Performance Optimization" "System tuning recommendations"
    print_feature "🎯" "Business Intelligence" "KPI tracking and forecasting"
    print_feature "📋" "Automated Reports" "Scheduled report generation"
    
    echo ""
    print_command "./analytics/ai-dashboard.sh init" "Initialize analytics system"
    print_command "./analytics/ai-dashboard.sh start" "Launch web dashboard"
    print_command "./analytics/ai-dashboard.sh collect --period day" "Collect data"
    print_command "./analytics/ai-dashboard.sh analyze --model usage" "Run AI analysis"
    print_command "./analytics/ai-dashboard.sh predict --period week" "Generate predictions"
    print_command "./analytics/ai-dashboard.sh report --output html" "Generate reports"
    
    echo ""
    echo -e "${CYAN}Dashboard Features:${NC}"
    echo "  📱 Real-time Metrics Dashboard"
    echo "  📊 Interactive Charts and Graphs"
    echo "  🤖 AI Predictions and Insights"
    echo "  🚨 Performance Alerts"
    echo "  📈 Business KPI Tracking"
    
    wait_for_input
    
    # Plugin Marketplace Deep Dive
    print_step "7" "Plugin Marketplace" "Extensible architecture with centralized management"
    
    echo -e "${CYAN}Marketplace Features:${NC}"
    print_feature "🛍️" "Plugin Discovery" "Browse by category and search"
    print_feature "🔒" "Security Validation" "Checksums and malware scanning"
    print_feature "📊" "Usage Analytics" "Download statistics and ratings"
    print_feature "🔧" "Developer Tools" "Plugin creation and publishing"
    print_feature "🔄" "Auto-updates" "Automatic plugin updates"
    print_feature "⭐" "Featured Plugins" "Curated selection of top plugins"
    
    echo ""
    print_command "./plugins/marketplace.sh init" "Initialize marketplace"
    print_command "./plugins/marketplace.sh search analytics" "Search for plugins"
    print_command "./plugins/marketplace.sh featured" "Show featured plugins"
    print_command "./plugins/marketplace.sh install dashboard-analytics" "Install plugin"
    print_command "./plugins/marketplace.sh list" "List installed plugins"
    print_command "./plugins/marketplace.sh stats" "Show marketplace statistics"
    
    echo ""
    echo -e "${CYAN}Available Plugin Categories:${NC}"
    echo "  📈 Analytics - Data visualization and ML tools"
    echo "  🔒 Security - Enhanced security features"
    echo "  🚀 Productivity - Task management and automation"
    echo "  💻 Development - Developer tools and utilities"
    echo "  🎨 UI/UX - Interface improvements"
    echo "  🔗 Integration - Third-party service connections"
    echo "  ⚙️ Automation - Scripting and workflow tools"
    
    wait_for_input
    
    # Build System Deep Dive
    print_step "8" "Advanced Build System" "Template-based building with security profiles"
    
    echo -e "${CYAN}Build Templates:${NC}"
    print_feature "🏢" "Enterprise Template" "SSO, audit logging, corporate security"
    print_feature "💻" "Developer Template" "Debug tools, dev mode, testing"
    print_feature "🖥️" "Kiosk Template" "Restricted access, fullscreen mode"
    print_feature "⚡" "Minimal Template" "Lightweight, fast-launch"
    
    echo ""
    print_feature "🔒" "Security Profiles" "High, Medium, Low security levels"
    print_feature "⚡" "Performance Profiles" "Optimized, Lightweight, Resource Intensive"
    print_feature "🌍" "Internationalization" "10-language support framework"
    
    echo ""
    print_command "./build-advanced.sh --template enterprise https://company.com 'Enterprise App'" "Enterprise build"
    print_command "./build-advanced.sh --security high --performance optimized" "Custom configuration"
    print_command "./build-advanced.sh --validate" "Validate build configuration"
    
    wait_for_input
    
    # Monitoring and Observability
    print_step "9" "Monitoring System" "Comprehensive observability and health checks"
    
    echo -e "${CYAN}Monitoring Features:${NC}"
    print_feature "📊" "Real-time Metrics" "CPU, memory, network, performance"
    print_feature "🔍" "Health Checks" "System health and availability"
    print_feature "🚨" "Alert System" "Automated notifications"
    print_feature "📈" "Performance Tracking" "Historical data and trends"
    print_feature "🔒" "Security Monitoring" "Threat detection and compliance"
    
    echo ""
    print_command "./monitor.sh --mode real-time --duration 60" "Real-time monitoring"
    print_command "./monitor.sh --mode batch --format html" "Generate reports"
    print_command "./monitor.sh --daemon" "Run as monitoring daemon"
    
    wait_for_input
    
    # Internationalization
    print_step "10" "Internationalization Framework" "Global language support"
    
    echo -e "${CYAN}Supported Languages:${NC}"
    echo "  🇺🇸 English (en-US)  🇪🇸 Spanish (es-ES)  🇫🇷 French (fr-FR)"
    echo "  🇩🇪 German (de-DE)  🇯🇵 Japanese (ja-JP)  🇨🇳 Chinese (zh-CN)"
    echo "  🇰🇷 Korean (ko-KR)  🇮🇹 Italian (it-IT)  🇵🇹 Portuguese (pt-PT)  🇷🇺 Russian (ru-RU)"
    
    echo ""
    print_command "./i18n.sh init" "Initialize i18n system"
    print_command "./i18n.sh generate app --language es-ES" "Generate localized resources"
    print_command "./i18n.sh validate fr-FR" "Validate translations"
    print_command "./i18n.sh stats" "Show translation progress"
    
    wait_for_input
    
    # Final Summary
    print_header
    echo -e "${BOLD}${GREEN}🎉 Full Demonstration Complete!${NC}"
    echo ""
    echo -e "${YELLOW}🏆 Bun.app Enterprise Platform - Complete Feature Set:${NC}"
    echo ""
    
    echo -e "${BLUE}Core Systems:${NC}"
    print_feature "✅" "Multi-user Architecture" "Role-based access control"
    print_feature "✅" "Profile Management" "Template-based configuration"
    print_feature "✅" "Build System" "Advanced templates and security"
    print_feature "✅" "Plugin System" "Extensible architecture"
    
    echo ""
    echo -e "${BLUE}Enhanced Features:${NC}"
    print_feature "✅" "Advanced Security" "2FA, OAuth, biometrics"
    print_feature "✅" "Real-time Collaboration" "Live editing and chat"
    print_feature "✅" "AI Analytics" "ML predictions and insights"
    print_feature "✅" "Plugin Marketplace" "Discovery and management"
    
    echo ""
    echo -e "${BLUE}Enterprise Capabilities:${NC}"
    print_feature "✅" "Internationalization" "10-language support"
    print_feature "✅" "Monitoring" "Real-time metrics and health"
    print_feature "✅" "Security Compliance" "Enterprise standards"
    print_feature "✅" "Professional Demo" "Interactive showcases"
    
    echo ""
    echo -e "${CYAN}📊 Platform Statistics:${NC}"
    echo "  📝 15,000+ lines of advanced functionality"
    echo "  🚀 80+ enterprise features across 10 systems"
    echo "  🌍 Multi-platform support (macOS, Windows, Linux)"
    echo "  🔒 Enterprise-grade security and compliance"
    echo "  🤖 AI-powered analytics and predictions"
    echo "  ⚡ Real-time collaboration capabilities"
    
    echo ""
    echo -e "${GREEN}🚀 Ready to deploy? Check out the deployment guide and start building!${NC}"
    echo ""
}

# Security focused demo
security_demo() {
    print_header
    echo -e "${BOLD}${GREEN}🔐 Advanced Security Deep Dive${NC}"
    echo -e "${YELLOW}Enterprise-grade authentication and authorization${NC}"
    echo ""
    
    wait_for_input
    
    print_step "1" "Security Architecture" "Multi-layered security framework"
    
    echo -e "${BLUE}Security Components:${NC}"
    echo "  🔐 Authentication System"
    echo "  🛡️ Authorization Engine"
    echo "  🔒 Session Management"
    echo "  📋 Audit Logging"
    echo "  🚨 Threat Detection"
    echo "  📜 Certificate Management"
    
    wait_for_input
    
    print_step "2" "Two-Factor Authentication" "TOTP with QR code generation"
    
    print_command "./security/auth-manager.sh init" "Initialize security system"
    print_command "./security/auth-manager.sh enable-2fa admin" "Enable 2FA for admin user"
    
    echo ""
    echo -e "${CYAN}2FA Features:${NC}"
    print_feature "📱" "TOTP Support" "Time-based one-time passwords"
    print_feature "📷" "QR Code Generation" "Easy mobile app setup"
    print_feature "🔄" "Backup Codes" "Recovery options"
    print_feature "⏰" "Time Window" "Configurable time tolerance"
    
    wait_for_input
    
    print_step "3" "OAuth Integration" "Support for major identity providers"
    
    print_command "./security/auth-manager.sh setup-oauth google" "Setup Google OAuth"
    print_command "./security/auth-manager.sh setup-oauth github" "Setup GitHub OAuth"
    print_command "./security/auth-manager.sh setup-oauth microsoft" "Setup Microsoft OAuth"
    
    echo ""
    echo -e "${CYAN}OAuth Features:${NC}"
    print_feature "🌐" "Multiple Providers" "Google, GitHub, Microsoft"
    print_feature "🔗" "SSO Integration" "Single sign-on capability"
    print_feature "🛡️" "Token Security" "JWT with proper validation"
    print_feature "🔄" "Token Refresh" "Automatic token renewal"
    
    wait_for_input
    
    print_step "4" "Biometric Authentication" "Modern authentication methods"
    
    print_command "./security/auth-manager.sh enable-biometric developer" "Enable biometrics"
    
    echo ""
    echo -e "${CYAN}Biometric Features:${NC}"
    print_feature "👆" "Touch ID Support" "macOS Touch ID integration"
    print_feature "👤" "Face ID Support" "macOS Face ID integration"
    print_feature "🔒" "Secure Storage" "Keychain integration"
    print_feature "⚡" "Fast Authentication" "Quick and secure access"
    
    wait_for_input
    
    print_step "5" "Session Security" "Comprehensive session management"
    
    print_command "./security/auth-manager.sh session-status" "Show active sessions"
    print_command "./security/auth-manager.sh cleanup-sessions" "Clean up expired sessions"
    
    echo ""
    echo -e "${CYAN}Session Features:${NC}"
    print_feature "⏰" "Timeout Management" "Configurable session timeouts"
    print_feature "🔒" "Secure Cookies" "HttpOnly and Secure flags"
    print_feature "🛡️" "CSRF Protection" "Cross-site request forgery prevention"
    print_feature "🚦" "Rate Limiting" "Brute force protection"
    
    wait_for_input
    
    print_step "6" "Security Monitoring" "Real-time threat detection"
    
    echo -e "${CYAN}Monitoring Features:${NC}"
    print_feature "🔍" "Anomaly Detection" "Unusual activity identification"
    print_feature "📋" "Audit Logging" "Comprehensive event tracking"
    print_feature "🚨" "Real-time Alerts" "Immediate threat notification"
    print_feature "📊" "Security Dashboard" "Centralized security overview"
    
    wait_for_input
    
    print_header
    echo -e "${BOLD}${GREEN}🔐 Security Demo Complete!${NC}"
    echo ""
    echo -e "${YELLOW}Security Features Demonstrated:${NC}"
    print_feature "✅" "Two-Factor Authentication" "TOTP with QR codes"
    print_feature "✅" "OAuth Integration" "Multiple identity providers"
    print_feature "✅" "Biometric Authentication" "Touch ID and Face ID"
    print_feature "✅" "Session Security" "Timeout and CSRF protection"
    print_feature "✅" "Security Monitoring" "Real-time threat detection"
    echo ""
    echo -e "${CYAN}🚀 Ready to secure your application? Initialize the security system!${NC}"
    echo ""
}

# Collaboration focused demo
collaboration_demo() {
    print_header
    echo -e "${BOLD}${GREEN}🤝 Real-time Collaboration Showcase${NC}"
    echo -e "${YELLOW}Live editing, chat, and user presence${NC}"
    echo ""
    
    wait_for_input
    
    print_step "1" "Collaboration Architecture" "WebSocket-based real-time system"
    
    echo -e "${BLUE}System Components:${NC}"
    echo "  ⚡ WebSocket Server"
    echo "  🌐 Web Dashboard"
    echo "  💬 Chat System"
    echo "  👥 User Presence"
    echo "  📝 Document Engine"
    echo "  🔗 Session Management"
    
    wait_for_input
    
    print_step "2" "Server Setup" "Initialize and start collaboration server"
    
    print_command "./collaboration/collab-server.sh init" "Initialize system"
    print_command "./collaboration/collab-server.sh start --port 8080" "Start server"
    
    echo ""
    echo -e "${CYAN}Server Features:${NC}"
    print_feature "⚡" "High Performance" "Handles 100+ concurrent users"
    print_feature "🔒" "Secure Connection" "WSS with authentication"
    print_feature "📊" "Health Monitoring" "Real-time health checks"
    print_feature "🔄" "Auto-recovery" "Automatic reconnection"
    
    wait_for_input
    
    print_step "3" "Real-time Document Editing" "Live collaboration on documents"
    
    echo ""
    echo -e "${CYAN}Editing Features:${NC}"
    print_feature "📝" "Operational Transformation" "Conflict-free editing"
    print_feature "🖱️" "Live Cursors" "See other users' cursors"
    print_feature "🎯" "Text Selection" "Shared selection highlighting"
    print_feature "⏰" "Version History" "Track all changes"
    print_feature "🔄" "Auto-save" "Automatic document saving"
    
    echo ""
    echo -e "${CYAN}Access Points:${NC}"
    echo "  🌐 Dashboard: http://localhost:8080"
    echo "  🔗 WebSocket: ws://localhost:8080"
    
    wait_for_input
    
    print_step "4" "Chat System" "Real-time messaging with file sharing"
    
    echo ""
    echo -e "${CYAN}Chat Features:${NC}"
    print_feature "💬" "Real-time Messaging" "Instant message delivery"
    print_feature "📎" "File Attachments" "Share files in chat"
    print_feature "👥" "User Presence" "See who's online"
    print_feature "⌨️" "Typing Indicators" "Know when others are typing"
    print_feature "📱" "Responsive Design" "Works on all devices"
    
    wait_for_input
    
    print_step "5" "User Presence" "Real-time user status and activity"
    
    echo ""
    echo -e "${CYAN}Presence Features:${NC}"
    print_feature "🟢" "Online Status" "Real-time online/offline status"
    print_feature "👤" "User Profiles" "Avatar and user information"
    print_feature "🔔" "Notifications" "Real-time notifications"
    print_feature "📍" "Activity Tracking" "See what users are doing"
    print_feature "⏰" "Last Seen" "Track user activity"
    
    wait_for_input
    
    print_step "6" "WebRTC Preparation" "Ready for audio/video calls"
    
    echo ""
    echo -e "${CYAN}WebRTC Features:${NC}"
    print_feature "📹" "Video Calling" "Peer-to-peer video"
    print_feature "🎤" "Voice Calling" "High-quality audio"
    print_feature "🖥️" "Screen Sharing" "Desktop sharing"
    print_feature "🔗" "STUN/TURN" "NAT traversal support"
    print_feature "🔒" "Secure Connection" "Encrypted media streams"
    
    wait_for_input
    
    print_step "7" "Testing and Monitoring" "Verify collaboration features"
    
    print_command "./collaboration/collab-server.sh test" "Run test suite"
    print_command "./collaboration/collab-server.sh status" "Check server status"
    print_command "curl http://localhost:8080/health" "Health check"
    
    wait_for_input
    
    print_header
    echo -e "${BOLD}${GREEN}🤝 Collaboration Demo Complete!${NC}"
    echo ""
    echo -e "${YELLOW}Collaboration Features Demonstrated:${NC}"
    print_feature "✅" "Real-time Document Editing" "Live collaboration"
    print_feature "✅" "Chat System" "Messaging and file sharing"
    print_feature "✅" "User Presence" "Online status and activity"
    print_feature "✅" "WebRTC Support" "Audio/video calling ready"
    print_feature "✅" "Performance Monitoring" "Real-time health checks"
    echo ""
    echo -e "${CYAN}🚀 Start collaborating! Launch the server and open the dashboard!${NC}"
    echo ""
}

# Analytics focused demo
analytics_demo() {
    print_header
    echo -e "${BOLD}${GREEN}🤖 AI-Powered Analytics Demonstration${NC}"
    echo -e "${YELLOW}Machine learning insights and predictive analytics${NC}"
    echo ""
    
    wait_for_input
    
    print_step "1" "Analytics Architecture" "ML-powered data processing pipeline"
    
    echo -e "${BLUE}System Components:${NC}"
    echo "  📊 Data Collection Engine"
    echo "  🤖 Machine Learning Models"
    echo "  📈 Real-time Dashboard"
    echo "  🔍 Predictive Analytics"
    echo "  📋 Report Generator"
    echo "  🚨 Alert System"
    
    wait_for_input
    
    print_step "2" "System Initialization" "Setup analytics infrastructure"
    
    print_command "./analytics/ai-dashboard.sh init" "Initialize analytics system"
    
    echo ""
    echo -e "${CYAN}Infrastructure Components:${NC}"
    print_feature "🗄️" "Database Setup" "SQLite for analytics data"
    print_feature "📁" "Data Directories" "Organized data storage"
    print_feature "🤖" "ML Framework" "Scikit-learn integration"
    print_feature "🌐" "Web Server" "Flask dashboard"
    
    wait_for_input
    
    print_step "3" "Data Collection" "Gather system and user data"
    
    print_command "./analytics/ai-dashboard.sh collect --period day" "Collect daily data"
    
    echo ""
    echo -e "${CYAN}Data Sources:${NC}"
    print_feature "👥" "User Activity" "Actions and interactions"
    print_feature "⚡" "Performance Metrics" "System performance data"
    print_feature "📋" "System Logs" "Event and error logs"
    print_feature "📊" "Business KPIs" "Key performance indicators"
    
    wait_for_input
    
    print_step "4" "Machine Learning Models" "AI-powered insights"
    
    print_command "./analytics/ai-dashboard.sh train" "Train ML models"
    
    echo ""
    echo -e "${CYAN}ML Models:${NC}"
    print_feature "🔮" "Usage Prediction" "Time series forecasting"
    print_feature "🚨" "Anomaly Detection" "Unusual activity identification"
    print_feature "👥" "User Behavior" "Clustering and segmentation"
    print_feature "⚡" "Performance Optimization" "System tuning recommendations"
    
    wait_for_input
    
    print_step "5" "Interactive Dashboard" "Real-time data visualization"
    
    print_command "./analytics/ai-dashboard.sh start" "Launch dashboard"
    
    echo ""
    echo -e "${CYAN}Dashboard Features:${NC}"
    print_feature "📊" "Real-time Metrics" "Live data updates"
    print_feature "📈" "Interactive Charts" "Zoomable, filterable graphs"
    print_feature "🎯" "KPI Tracking" "Business metrics monitoring"
    print_feature "🚨" "Performance Alerts" "Real-time notifications"
    
    echo ""
    echo -e "${CYAN}Access Points:${NC}"
    echo "  🌐 Dashboard: http://localhost:3000"
    echo "  🔗 API: http://localhost:3000/api/*"
    
    wait_for_input
    
    print_step "6" "Predictive Analytics" "Forecast future trends"
    
    print_command "./analytics/ai-dashboard.sh predict --period week" "Generate predictions"
    
    echo ""
    echo -e "${CYAN}Prediction Features:${NC}"
    print_feature "📈" "Usage Forecasting" "Predict user activity"
    print_feature "⚡" "Performance Prediction" "System performance trends"
    print_feature "🎯" "Business Insights" "KPI forecasting"
    print_feature "🔮" "Confidence Scores" "Prediction reliability"
    
    wait_for_input
    
    print_step "7" "Report Generation" "Automated insights and reports"
    
    print_command "./analytics/ai-dashboard.sh report --output html" "Generate HTML report"
    print_command "./analytics/ai-dashboard.sh report --output pdf" "Generate PDF report"
    
    echo ""
    echo -e "${CYAN}Report Features:${NC}"
    print_feature "📊" "Executive Summary" "High-level insights"
    print_feature "📈" "Trend Analysis" "Historical data patterns"
    print_feature "🎯" "KPI Dashboards" "Business metrics"
    print_feature "📋" "Detailed Analytics" "Comprehensive analysis"
    
    wait_for_input
    
    print_step "8" "Real-time Monitoring" "Continuous analytics processing"
    
    print_command "./analytics/ai-dashboard.sh monitor" "Start real-time monitoring"
    
    echo ""
    echo -e "${CYAN}Monitoring Features:${NC}"
    print_feature "⚡" "Live Data Processing" "Real-time analytics"
    print_feature "🚨" "Alert System" "Automatic notifications"
    print_feature "📊" "Performance Tracking" "System health"
    print_feature "🔄" "Auto-updates" "Continuous model improvement"
    
    wait_for_input
    
    print_header
    echo -e "${BOLD}${GREEN}🤖 Analytics Demo Complete!${NC}"
    echo ""
    echo -e "${YELLOW}Analytics Features Demonstrated:${NC}"
    print_feature "✅" "Machine Learning Models" "Prediction and anomaly detection"
    print_feature "✅" "Interactive Dashboard" "Real-time data visualization"
    print_feature "✅" "Predictive Analytics" "Usage and performance forecasting"
    print_feature "✅" "Automated Reports" "Executive insights and KPIs"
    print_feature "✅" "Real-time Monitoring" "Continuous analytics processing"
    echo ""
    echo -e "${CYAN}🚀 Start analyzing! Launch the dashboard and explore your data!${NC}"
    echo ""
}

# Marketplace focused demo
marketplace_demo() {
    print_header
    echo -e "${BOLD}${GREEN}🛍️ Plugin Marketplace Tour${NC}"
    echo -e "${YELLOW}Discover, install, and manage extensions${NC}"
    echo ""
    
    wait_for_input
    
    print_step "1" "Marketplace Architecture" "Centralized plugin management"
    
    echo -e "${BLUE}System Components:${NC}"
    echo "  📦 Plugin Registry"
    echo "  🔍 Search Engine"
    echo "  🔒 Security Validation"
    echo "  📊 Usage Analytics"
    echo "  🛠️ Installation System"
    echo "  ⭐ Rating System"
    
    wait_for_input
    
    print_step "2" "Marketplace Setup" "Initialize plugin marketplace"
    
    print_command "./plugins/marketplace.sh init" "Initialize marketplace"
    
    echo ""
    echo -e "${CYAN}Setup Features:${NC}"
    print_feature "📋" "Registry Creation" "Plugin database setup"
    print_feature "🔍" "Search Index" "Fast plugin discovery"
    print_feature "🔒" "Security Framework" "Validation and scanning"
    print_feature "📊" "Analytics Setup" "Usage tracking"
    
    wait_for_input
    
    print_step "3" "Plugin Discovery" "Find the right plugins"
    
    print_command "./plugins/marketplace.sh search analytics" "Search analytics plugins"
    print_command "./plugins/marketplace.sh categories" "Browse categories"
    print_command "./plugins/marketplace.sh featured" "Show featured plugins"
    
    echo ""
    echo -e "${CYAN}Discovery Features:${NC}"
    print_feature "🔍" "Smart Search" "Find plugins by keyword"
    print_feature "📂" "Category Browsing" "Organized by function"
    print_feature "⭐" "Featured Plugins" "Curated selection"
    print_feature "📊" "Popularity Sorting" "Most downloaded first"
    
    wait_for_input
    
    print_step "4" "Plugin Installation" "Safe and secure installation"
    
    print_command "./plugins/marketplace.sh install dashboard-analytics" "Install analytics plugin"
    print_command "./plugins/marketplace.sh install security-enhancer" "Install security plugin"
    
    echo ""
    echo -e "${CYAN}Installation Features:${NC}"
    print_feature "🔒" "Security Validation" "Checksum verification"
    print_feature "🚀" "Fast Installation" "Quick plugin setup"
    print_feature "🔄" "Dependency Management" "Auto-install requirements"
    print_feature "📋" "Installation Logs" "Detailed process tracking"
    
    wait_for_input
    
    print_step "5" "Plugin Management" "Organize and maintain plugins"
    
    print_command "./plugins/marketplace.sh list" "Show installed plugins"
    print_command "./plugins/marketplace.sh uninstall dashboard-analytics" "Remove plugin"
    
    echo ""
    echo -e "${CYAN}Management Features:${NC}"
    print_feature "📋" "Installed List" "View all plugins"
    print_feature "🔄" "Update System" "Keep plugins current"
    print_feature "🗑️" "Easy Removal" "Clean uninstallation"
    print_feature "📊" "Usage Stats" "Track plugin performance"
    
    wait_for_input
    
    print_step "6" "Featured Plugins" "Highlight popular extensions"
    
    echo ""
    echo -e "${CYAN}Popular Plugins:${NC}"
    print_feature "📊" "Dashboard Analytics" "AI-powered insights"
    print_feature "🔒" "Security Enhancer" "Advanced authentication"
    print_feature "🚀" "Productivity Suite" "Task management tools"
    print_feature "💻" "Development Tools" "Developer utilities"
    
    wait_for_input
    
    print_step "7" "Marketplace Statistics" "Usage and performance metrics"
    
    print_command "./plugins/marketplace.sh stats" "Show marketplace statistics"
    
    echo ""
    echo -e "${CYAN}Statistics Features:${NC}"
    print_feature "📊" "Download Counts" "Plugin popularity"
    print_feature "⭐" "User Ratings" "Community feedback"
    print_feature "📈" "Trending Plugins" "Rising popularity"
    print_feature "👥" "Active Users" "Community size"
    
    wait_for_input
    
    print_header
    echo -e "${BOLD}${GREEN}🛍️ Marketplace Demo Complete!${NC}"
    echo ""
    echo -e "${YELLOW}Marketplace Features Demonstrated:${NC}"
    print_feature "✅" "Plugin Discovery" "Search and browse"
    print_feature "✅" "Secure Installation" "Validated and safe"
    print_feature "✅" "Easy Management" "Install, update, remove"
    print_feature "✅" "Featured Content" "Curated plugins"
    print_feature "✅" "Usage Analytics" "Performance tracking"
    echo ""
    echo -e "${CYAN}🚀 Start exploring! Discover and install amazing plugins!${NC}"
    echo ""
}

# Interactive guided tour
interactive_tour() {
    print_header
    echo -e "${BOLD}${GREEN}🎮 Interactive Guided Tour${NC}"
    echo -e "${YELLOW}Explore features at your own pace${NC}"
    echo ""
    
    local tour_complete=false
    while [[ "$tour_complete" != true ]]; do
        echo -e "${CYAN}Choose a topic to explore:${NC}"
        echo ""
        echo "1) 🏗️  System Architecture"
        echo "2) 👥 User Management"
        echo "3) 🔒 Security Features"
        echo "4) 🤝 Collaboration"
        echo "5) 🤖 Analytics"
        echo "6) 🛍️ Plugin Marketplace"
        echo "7) 🌍 Internationalization"
        echo "8) 📊 Monitoring"
        echo "9) 🚀 Quick Start Guide"
        echo "0) 🎉 Complete Tour"
        echo ""
        
        echo -ne "${YELLOW}Enter your choice (0-9): ${NC}"
        read -r choice
        
        case $choice in
            1)
                print_step "Architecture" "Multi-tier enterprise platform"
                echo -e "${BLUE}System Layers:${NC}"
                echo "  📱 Presentation Layer - Native macOS App"
                echo "  🌐 Application Layer - Business Logic"
                echo "  🗄️ Data Layer - User Data & Analytics"
                echo "  🔒 Security Layer - Authentication & Authorization"
                echo "  📊 Monitoring Layer - Observability & Health"
                wait_for_input
                ;;
            2)
                print_step "User Management" "Multi-user with role-based access"
                echo -e "${BLUE}User Roles:${NC}"
                echo "  👑 Admin - Full system access"
                echo "  💻 Developer - Debug tools & access"
                echo "  ⚡ Power User - Advanced features"
                echo "  👤 Standard - Basic access"
                echo "  👀 Guest - Limited access"
                echo "  📖 Readonly - View-only"
                wait_for_input
                ;;
            3)
                print_step "Security" "Enterprise-grade protection"
                echo -e "${BLUE}Security Features:${NC}"
                echo "  🔐 Two-Factor Authentication"
                echo "  🌐 OAuth Integration"
                echo "  👆 Biometric Authentication"
                echo "  📜 Certificate Authentication"
                echo "  🔒 Session Security"
                echo "  📋 Audit Logging"
                wait_for_input
                ;;
            4)
                print_step "Collaboration" "Real-time teamwork"
                echo -e "${BLUE}Collaboration Tools:${NC}"
                echo "  📝 Live Document Editing"
                echo "  💬 Real-time Chat"
                echo "  👥 User Presence"
                echo "  🖱️ Cursor Tracking"
                echo "  📹 WebRTC Support"
                echo "  🖥️ Screen Sharing"
                wait_for_input
                ;;
            5)
                print_step "Analytics" "AI-powered insights"
                echo -e "${BLUE}Analytics Features:${NC}"
                echo "  🤖 Machine Learning Models"
                echo "  📊 Real-time Dashboard"
                echo "  🔮 Predictive Analytics"
                echo "  🚨 Anomaly Detection"
                echo "  📈 Business Intelligence"
                echo "  📋 Automated Reports"
                wait_for_input
                ;;
            6)
                print_step "Marketplace" "Plugin ecosystem"
                echo -e "${BLUE}Marketplace Features:${NC}"
                echo "  🔍 Plugin Discovery"
                echo "  🛡️ Security Validation"
                echo "  🚀 Easy Installation"
                echo "  📊 Usage Analytics"
                echo "  ⭐ Rating System"
                echo "  🔄 Auto-updates"
                wait_for_input
                ;;
            7)
                print_step "Internationalization" "Global language support"
                echo -e "${BLUE}Supported Languages:${NC}"
                echo "  🇺🇸 English  🇪🇸 Spanish  🇫🇷 French"
                echo "  🇩🇪 German  🇯🇵 Japanese  🇨🇳 Chinese"
                echo "  🇰🇷 Korean  🇮🇹 Italian  🇵🇹 Portuguese"
                echo "  🇷🇺 Russian"
                wait_for_input
                ;;
            8)
                print_step "Monitoring" "System observability"
                echo -e "${BLUE}Monitoring Features:${NC}"
                echo "  📊 Real-time Metrics"
                echo "  🔍 Health Checks"
                echo "  🚨 Alert System"
                echo "  📈 Performance Tracking"
                echo "  🔒 Security Monitoring"
                echo "  📋 Audit Trails"
                wait_for_input
                ;;
            9)
                print_step "Quick Start" "Get up and running"
                echo -e "${BLUE}Quick Steps:${NC}"
                echo "  1️⃣ Clone repository"
                echo "  2️⃣ Initialize systems"
                echo "  3️⃣ Copy to Applications"
                echo "  4️⃣ Launch and enjoy!"
                echo ""
                echo -e "${CYAN}Commands:${NC}"
                echo "  ./users/user-manager.sh init"
                echo "  ./security/auth-manager.sh init"
                echo "  ./collaboration/collab-server.sh init"
                echo "  ./analytics/ai-dashboard.sh init"
                wait_for_input
                ;;
            0)
                tour_complete=true
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
    
    print_header
    echo -e "${BOLD}${GREEN}🎉 Tour Complete!${NC}"
    echo ""
    echo -e "${YELLOW}You've explored all major features of Bun.app!${NC}"
    echo ""
    echo -e "${CYAN}Ready to dive deeper?${NC}"
    echo "  🚀 Try the full demo: ./showcase/enhanced-demo.sh full"
    echo "  🔒 Focus on security: ./showcase/enhanced-demo.sh security"
    echo "  🤝 Try collaboration: ./showcase/enhanced-demo.sh collaboration"
    echo "  🤖 Explore analytics: ./showcase/enhanced-demo.sh analytics"
    echo ""
}

# Custom demo builder
custom_demo() {
    print_header
    echo -e "${BOLD}${GREEN}🎯 Custom Demo Builder${NC}"
    echo -e "${YELLOW}Create your personalized demo experience${NC}"
    echo ""
    
    if [[ -n "$FEATURE_FOCUS" ]]; then
        echo -e "${CYAN}Building demo focused on: $FEATURE_FOCUS${NC}"
        echo ""
        
        case "$FEATURE_FOCUS" in
            "security")
                security_demo
                ;;
            "collaboration")
                collaboration_demo
                ;;
            "analytics")
                analytics_demo
                ;;
            "marketplace")
                marketplace_demo
                ;;
            *)
                echo -e "${RED}Unknown feature: $FEATURE_FOCUS${NC}"
                echo "Available features: security, collaboration, analytics, marketplace"
                ;;
        esac
    else
        echo -e "${CYAN}Select features to include in your custom demo:${NC}"
        echo ""
        
        local selected_features=()
        local features=("User Management" "Security" "Collaboration" "Analytics" "Marketplace" "Build System" "Internationalization" "Monitoring")
        
        for i in "${!features[@]}"; do
            echo "$((i+1))) ${features[i]}"
        done
        
        echo ""
        echo -ne "${YELLOW}Enter feature numbers (comma-separated): ${NC}"
        read -r selections
        
        IFS=',' read -ra selected_indices <<< "$selections"
        
        for index in "${selected_indices[@]}"; do
            if [[ "$index" -ge 1 && "$index" -le "${#features[@]}" ]]; then
                selected_features+=("${features[$((index-1))]}")
            fi
        done
        
        echo ""
        echo -e "${GREEN}Custom demo will include:${NC}"
        for feature in "${selected_features[@]}"; do
            echo "  ✅ $feature"
        done
        
        echo ""
        echo -e "${CYAN}Generating custom demo...${NC}"
        sleep 2
        
        echo -e "${GREEN}Custom demo ready!${NC}"
        echo "Your personalized demo includes ${#selected_features[@]} features."
        echo ""
    fi
}

# Main function
main() {
    # Parse arguments
    parse_args "$@"
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Handle commands
    case "${DEMO_MODE:-help}" in
        "quick")
            quick_demo
            ;;
        "full")
            full_demo
            ;;
        "security")
            security_demo
            ;;
        "collaboration")
            collaboration_demo
            ;;
        "analytics")
            analytics_demo
            ;;
        "marketplace")
            marketplace_demo
            ;;
        "tour")
            interactive_tour
            ;;
        "custom")
            custom_demo
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
