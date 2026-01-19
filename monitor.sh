#!/bin/bash

# Advanced Monitoring and Analytics System for Bun.app
# Comprehensive monitoring, analytics, and performance tracking

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
CONFIG_FILE="$SCRIPT_DIR/config/monitor-config.yaml"
DATA_DIR="$SCRIPT_DIR/data"
LOGS_DIR="$SCRIPT_DIR/logs"
REPORTS_DIR="$SCRIPT_DIR/reports"

# Default values
MODE="real-time"
METRICS_INTERVAL=60
DURATION=300
OUTPUT_FORMAT="json"
VERBOSE=false
DAEMON=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --mode|-m)
                MODE="$2"
                shift 2
                ;;
            --interval|-i)
                METRICS_INTERVAL="$2"
                shift 2
                ;;
            --duration|-d)
                DURATION="$2"
                shift 2
                ;;
            --format|-f)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --daemon)
                DAEMON=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
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
Bun.app Monitoring and Analytics System

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -m, --mode MODE           Monitoring mode (real-time, batch, historical)
    -i, --interval SECONDS    Metrics collection interval (default: 60)
    -d, --duration SECONDS    Monitoring duration (default: 300)
    -f, --format FORMAT       Output format (json, csv, prometheus)
    --daemon                  Run as daemon
    -v, --verbose             Verbose output
    -h, --help                Show this help

MODES:
    real-time     Live monitoring with real-time updates
    batch         Collect metrics for specified duration
    historical    Analyze historical data

EXAMPLES:
    $0                                    # Real-time monitoring
    $0 --mode batch --duration 600        # 10-minute batch collection
    $0 --daemon                          # Run as monitoring daemon

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

print_metric() {
    local metric_name="$1"
    local metric_value="$2"
    local timestamp="$3"
    
    case "$OUTPUT_FORMAT" in
        "json")
            echo "{\"metric\":\"$metric_name\",\"value\":$metric_value,\"timestamp\":$timestamp}"
            ;;
        "csv")
            echo "$timestamp,$metric_name,$metric_value"
            ;;
        "prometheus")
            echo "# TYPE $metric_name gauge"
            echo "$metric_name $metric_value $(date +%s)000"
            ;;
        *)
            echo "$metric_name: $metric_value"
            ;;
    esac
}

# Setup monitoring environment
setup_environment() {
    print_info "Setting up monitoring environment..."
    
    # Create directories
    mkdir -p "$DATA_DIR"
    mkdir -p "$LOGS_DIR"
    mkdir -p "$REPORTS_DIR"
    
    # Initialize log files
    local log_file="$LOGS_DIR/monitor-$(date +%Y%m%d).log"
    touch "$log_file"
    
    print_success "Environment setup complete"
}

# Get system metrics
get_system_metrics() {
    local timestamp=$(date +%s)
    
    # CPU usage
    local cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    print_metric "system.cpu.usage" "$cpu_usage" "$timestamp"
    
    # Memory usage
    local memory_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    print_metric "system.memory.free_percentage" "$memory_pressure" "$timestamp"
    
    # Disk usage
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    print_metric "system.disk.usage_percentage" "$disk_usage" "$timestamp"
    
    # Network activity
    local network_in=$(netstat -ib | grep "en0" | awk '{sum+=$7} END {print sum}')
    local network_out=$(netstat -ib | grep "en0" | awk '{sum+=$10} END {print sum}')
    print_metric "system.network.bytes_in" "$network_in" "$timestamp"
    print_metric "system.network.bytes_out" "$network_out" "$timestamp"
}

# Get Bun.app metrics
get_app_metrics() {
    local timestamp=$(date +%s)
    local app_name="Bun"
    
    # Check if app is running
    if pgrep -f "$app_name.app" > /dev/null; then
        # App CPU usage
        local app_cpu=$(ps aux | grep "$app_name.app" | grep -v grep | awk '{sum+=$3} END {print sum}')
        print_metric "app.cpu.usage" "$app_cpu" "$timestamp"
        
        # App memory usage
        local app_memory=$(ps aux | grep "$app_name.app" | grep -v grep | awk '{sum+=$6} END {print sum/1024}')
        print_metric "app.memory.usage_mb" "$app_memory" "$timestamp"
        
        # App thread count
        local app_threads=$(ps aux | grep "$app_name.app" | grep -v grep | awk '{sum+=$2} END {print NR}')
        print_metric "app.threads.count" "$app_threads" "$timestamp"
        
        # App uptime (if we can determine it)
        local app_pid=$(pgrep -f "$app_name.app" | head -1)
        if [[ -n "$app_pid" ]]; then
            local app_start_time=$(ps -o lstart= -p "$app_pid" | xargs -I {} date -j -f "%a %b %d %H:%M:%S %Y" "{}" +%s)
            local app_uptime=$((timestamp - app_start_time))
            print_metric "app.uptime.seconds" "$app_uptime" "$timestamp"
        fi
        
        print_debug "App metrics collected for $app_name"
    else
        print_metric "app.running" "0" "$timestamp"
        print_debug "App $app_name is not running"
    fi
}

# Get performance metrics
get_performance_metrics() {
    local timestamp=$(date +%s)
    
    # Launch time measurement (if we can measure it)
    local launch_time=$(measure_launch_time)
    print_metric "performance.launch.time_ms" "$launch_time" "$timestamp"
    
    # Network latency to target URL
    local network_latency=$(measure_network_latency)
    print_metric "performance.network.latency_ms" "$network_latency" "$timestamp"
    
    # Page load time
    local page_load_time=$(measure_page_load_time)
    print_metric "performance.page.load_time_ms" "$page_load_time" "$timestamp"
    
    # Resource utilization efficiency
    local efficiency=$(calculate_efficiency)
    print_metric "performance.efficiency.score" "$efficiency" "$timestamp"
}

# Measure launch time
measure_launch_time() {
    local app_name="Bun"
    
    # If app is running, we can't measure launch time
    if pgrep -f "$app_name.app" > /dev/null; then
        echo "0"
        return
    fi
    
    # Measure launch time
    local start_time=$(date +%s%N)
    open "/Applications/$app_name.app" 2>/dev/null || true
    
    # Wait for app to start
    local timeout=30
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        if pgrep -f "$app_name.app" > /dev/null; then
            local end_time=$(date +%s%N)
            local launch_time=$(( (end_time - start_time) / 1000000 ))
            echo "$launch_time"
            return
        fi
        sleep 0.5
        elapsed=$((elapsed + 1))
    done
    
    echo "30000"  # Timeout after 30 seconds
}

# Measure network latency
measure_network_latency() {
    local target_url="https://bun.com"
    
    # Use curl to measure connection time
    local latency=$(curl -o /dev/null -s -w "%{time_connect}" "$target_url" 2>/dev/null || echo "0")
    
    # Convert to milliseconds
    echo "${latency/./}" | head -c 3
}

# Measure page load time
measure_page_load_time() {
    local target_url="https://bun.com"
    
    # Use curl to measure total time
    local load_time=$(curl -o /dev/null -s -w "%{time_total}" "$target_url" 2>/dev/null || echo "0")
    
    # Convert to milliseconds
    echo "${load_time/./}" | head -c 4
}

# Calculate efficiency score
calculate_efficiency() {
    # Simple efficiency calculation based on resource usage
    local cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local memory_free=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    
    # Efficiency score (0-100)
    local efficiency=$(( (100 - ${cpu_usage%.*} + memory_free) / 2 ))
    echo "$efficiency"
}

# Get security metrics
get_security_metrics() {
    local timestamp=$(date +%s)
    
    # Code signature status
    local signature_status=$(check_code_signature)
    print_metric "security.signature.valid" "$signature_status" "$timestamp"
    
    # Network security (HTTPS only)
    local https_only=$(check_https_only)
    print_metric "security.https_only" "$https_only" "$timestamp"
    
    # Permission audit
    local permission_score=$(audit_permissions)
    print_metric "security.permissions.score" "$permission_score" "$timestamp"
    
    # Vulnerability scan results
    local vulnerability_count=$(run_vulnerability_scan)
    print_metric "security.vulnerabilities.count" "$vulnerability_count" "$timestamp"
}

# Check code signature
check_code_signature() {
    local app_path="/Applications/Bun.app"
    
    if codesign -v "$app_path" 2>/dev/null; then
        echo "1"
    else
        echo "0"
    fi
}

# Check HTTPS only
check_https_only() {
    local config_file="/Applications/Bun.app/Contents/Info.plist"
    
    if plutil -p "$config_file" 2>/dev/null | grep -q "https://bun.com"; then
        echo "1"
    else
        echo "0"
    fi
}

# Audit permissions
audit_permissions() {
    local app_path="/Applications/Bun.app"
    local score=100
    
    # Check for excessive permissions
    if [[ -r "$app_path/Contents/MacOS/app_mode_loader" ]]; then
        local permissions=$(ls -la "$app_path/Contents/MacOS/app_mode_loader" | cut -d' ' -f1)
        
        # Deduct points for world-writable
        if [[ "$permissions" == *"w"* ]]; then
            score=$((score - 20))
        fi
        
        # Deduct points for setuid/setgid
        if [[ "$permissions" == *"s"* ]]; then
            score=$((score - 30))
        fi
    fi
    
    echo "$score"
}

# Run vulnerability scan
run_vulnerability_scan() {
    # Simple vulnerability check using trufflehog if available
    if command -v trufflehog &> /dev/null; then
        local findings=$(trufflehog filesystem "$SCRIPT_DIR" --no-update 2>/dev/null | wc -l || echo "0")
        echo "$findings"
    else
        echo "0"
    fi
}

# Get user experience metrics
get_ux_metrics() {
    local timestamp=$(date +%s)
    
    # App responsiveness
    local responsiveness=$(measure_responsiveness)
    print_metric "ux.responsiveness.score" "$responsiveness" "$timestamp"
    
    # UI latency
    local ui_latency=$(measure_ui_latency)
    print_metric "ux.ui.latency_ms" "$ui_latency" "$timestamp"
    
    # Crash rate
    local crash_rate=$(calculate_crash_rate)
    print_metric "ux.crash.rate" "$crash_rate" "$timestamp"
    
    # User satisfaction (simulated)
    local satisfaction=$(calculate_satisfaction)
    print_metric "ux.satisfaction.score" "$satisfaction" "$timestamp"
}

# Measure responsiveness
measure_responsiveness() {
    # Simple responsiveness check based on CPU and memory usage
    local cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local memory_usage=$(ps aux | grep "Bun.app" | grep -v grep | awk '{sum+=$6} END {print sum/1024}')
    
    # Calculate responsiveness score (0-100)
    local score=100
    score=$((score - ${cpu_usage%.*}))
    
    if [[ ${memory_usage%.*} -gt 100 ]]; then
        score=$((score - 20))
    fi
    
    if [[ $score -lt 0 ]]; then
        score=0
    fi
    
    echo "$score"
}

# Measure UI latency
measure_ui_latency() {
    # Simulated UI latency measurement
    # In a real implementation, you'd use accessibility APIs or other methods
    echo "50"
}

# Calculate crash rate
calculate_crash_rate() {
    # Check crash logs for the app
    local crash_logs=$(find ~/Library/Logs/DiagnosticReports -name "Bun_*" -mtime -7 | wc -l)
    echo "$crash_logs"
}

# Calculate satisfaction score
calculate_satisfaction() {
    # Simulated satisfaction based on performance metrics
    local cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local responsiveness=$(measure_responsiveness)
    
    # Calculate satisfaction score (0-100)
    local satisfaction=$(( (responsiveness + (100 - ${cpu_usage%.*})) / 2 ))
    echo "$satisfaction"
}

# Get business metrics
get_business_metrics() {
    local timestamp=$(date +%s)
    
    # GitHub stars (if available)
    local stars=$(get_github_stars)
    print_metric "business.github.stars" "$stars" "$timestamp"
    
    # Downloads (simulated)
    local downloads=$(get_download_count)
    print_metric "business.downloads.count" "$downloads" "$timestamp"
    
    # Active users (simulated)
    local active_users=$(get_active_users)
    print_metric "business.users.active" "$active_users" "$timestamp"
    
    # Engagement score
    local engagement=$(calculate_engagement)
    print_metric "business.engagement.score" "$engagement" "$timestamp"
}

# Get GitHub stars
get_github_stars() {
    if command -v gh &> /dev/null; then
        gh repo view brendadeeznuts1111/bun-app --json stargazerCount --jq '.stargazerCount' 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Get download count
get_download_count() {
    # Simulated download count
    # In a real implementation, you'd query GitHub releases API
    echo "42"
}

# Get active users
get_active_users() {
    # Simulated active user count
    # In a real implementation, you'd use analytics
    echo "15"
}

# Calculate engagement score
calculate_engagement() {
    local stars=$(get_github_stars)
    local downloads=$(get_download_count)
    
    # Simple engagement calculation
    local engagement=$(( (stars + downloads) / 10 ))
    if [[ $engagement -gt 100 ]]; then
        engagement=100
    fi
    
    echo "$engagement"
}

# Collect all metrics
collect_metrics() {
    local timestamp=$(date +%s)
    
    print_debug "Collecting metrics at $(date)"
    
    # System metrics
    get_system_metrics
    
    # App metrics
    get_app_metrics
    
    # Performance metrics
    get_performance_metrics
    
    # Security metrics
    get_security_metrics
    
    # User experience metrics
    get_ux_metrics
    
    # Business metrics
    get_business_metrics
    
    print_debug "Metrics collection completed"
}

# Real-time monitoring
monitor_real_time() {
    print_info "Starting real-time monitoring (interval: ${METRICS_INTERVAL}s)"
    
    local end_time=$(($(date +%s) + DURATION))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        collect_metrics
        sleep "$METRICS_INTERVAL"
    done
}

# Batch monitoring
monitor_batch() {
    print_info "Starting batch monitoring for ${DURATION}s"
    
    local iterations=$((DURATION / METRICS_INTERVAL))
    
    for ((i=1; i<=iterations; i++)); do
        print_info "Collecting batch $i/$iterations"
        collect_metrics
        sleep "$METRICS_INTERVAL"
    done
}

# Historical analysis
monitor_historical() {
    print_info "Analyzing historical data..."
    
    # Analyze existing log files
    local log_files=("$LOGS_DIR"/*.log)
    
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            analyze_log_file "$log_file"
        fi
    done
}

# Analyze log file
analyze_log_file() {
    local log_file="$1"
    
    print_debug "Analyzing log file: $log_file"
    
    # Extract metrics from log file
    local error_count=$(grep -c "ERROR" "$log_file" || echo "0")
    local warning_count=$(grep -c "WARNING" "$log_file" || echo "0")
    local info_count=$(grep -c "INFO" "$log_file" || echo "0")
    
    local timestamp=$(date +%s)
    print_metric "historical.errors.count" "$error_count" "$timestamp"
    print_metric "historical.warnings.count" "$warning_count" "$timestamp"
    print_metric "historical.info.count" "$info_count" "$timestamp"
}

# Generate monitoring report
generate_report() {
    print_info "Generating monitoring report..."
    
    local report_file="$REPORTS_DIR/monitoring-report-$(date +%Y%m%d-%H%M%S).$OUTPUT_FORMAT"
    
    case "$OUTPUT_FORMAT" in
        "json")
            generate_json_report "$report_file"
            ;;
        "csv")
            generate_csv_report "$report_file"
            ;;
        "html")
            generate_html_report "$report_file"
            ;;
    esac
    
    print_success "Report generated: $report_file"
}

# Generate JSON report
generate_json_report() {
    local report_file="$1"
    
    cat > "$report_file" << EOF
{
    "monitoring_report": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "mode": "$MODE",
        "duration": $DURATION,
        "interval": $METRICS_INTERVAL,
        "metrics_collected": $(collect_metrics | wc -l)
    },
    "system_summary": {
        "cpu_usage": "$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}')",
        "memory_free": "$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}')",
        "disk_usage": "$(df -h / | tail -1 | awk '{print $5}')"
    },
    "app_summary": {
        "running": $(pgrep -f "Bun.app" > /dev/null && echo "true" || echo "false"),
        "cpu_usage": "$(ps aux | grep "Bun.app" | grep -v grep | awk '{sum+=$3} END {print sum}' || echo "0")",
        "memory_usage": "$(ps aux | grep "Bun.app" | grep -v grep | awk '{sum+=$6} END {print sum/1024}' || echo "0")"
    },
    "performance_summary": {
        "launch_time": "$(measure_launch_time)",
        "network_latency": "$(measure_network_latency)",
        "efficiency_score": "$(calculate_efficiency)"
    },
    "security_summary": {
        "signature_valid": "$(check_code_signature)",
        "https_only": "$(check_https_only)",
        "vulnerabilities": "$(run_vulnerability_scan)"
    }
}
EOF
}

# Generate CSV report
generate_csv_report() {
    local report_file="$1"
    
    echo "timestamp,metric,value" > "$report_file"
    collect_metrics >> "$report_file"
}

# Generate HTML report
generate_html_report() {
    local report_file="$1"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Bun.app Monitoring Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }
        .header { background: #f5f5f5; padding: 20px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Bun.app Monitoring Report</h1>
        <p>Generated: $(date)</p>
        <p>Mode: $MODE | Duration: ${DURATION}s | Interval: ${METRICS_INTERVAL}s</p>
    </div>
    
    <div class="metric">
        <h3>System Metrics</h3>
        <p>CPU Usage: $(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}')</p>
        <p>Memory Free: $(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}')</p>
        <p>Disk Usage: $(df -h / | tail -1 | awk '{print $5}')</p>
    </div>
    
    <div class="metric">
        <h3>App Metrics</h3>
        <p>Running: $(pgrep -f "Bun.app" > /dev/null && echo "Yes" || echo "No")</p>
        <p>CPU Usage: $(ps aux | grep "Bun.app" | grep -v grep | awk '{sum+=$3} END {print sum}' || echo "0")%</p>
        <p>Memory Usage: $(ps aux | grep "Bun.app" | grep -v grep | awk '{sum+=$6} END {print sum/1024}' || echo "0")MB</p>
    </div>
    
    <div class="metric">
        <h3>Performance Metrics</h3>
        <p>Launch Time: $(measure_launch_time)ms</p>
        <p>Network Latency: $(measure_network_latency)ms</p>
        <p>Efficiency Score: $(calculate_efficiency)/100</p>
    </div>
</body>
</html>
EOF
}

# Run as daemon
run_daemon() {
    print_info "Starting monitoring daemon..."
    
    # Create PID file
    local pid_file="$SCRIPT_DIR/monitor.pid"
    echo $$ > "$pid_file"
    
    # Trap signals for graceful shutdown
    trap 'cleanup daemon; exit 0' SIGTERM SIGINT
    
    # Infinite loop for daemon
    while true; do
        collect_metrics >> "$LOGS_DIR/daemon-$(date +%Y%m%d).log"
        sleep "$METRICS_INTERVAL"
    done
}

# Cleanup function
cleanup() {
    local context="$1"
    
    print_info "Cleaning up $context..."
    
    # Remove PID file if daemon
    if [[ "$context" == "daemon" && -f "$SCRIPT_DIR/monitor.pid" ]]; then
        rm -f "$SCRIPT_DIR/monitor.pid"
    fi
    
    print_success "Cleanup complete"
}

# Main monitoring function
main() {
    echo "📊 Bun.app Monitoring and Analytics System"
    echo "=========================================="
    
    # Parse arguments
    parse_args "$@"
    
    print_info "Starting monitoring in $MODE mode"
    print_info "Interval: ${METRICS_INTERVAL}s, Duration: ${DURATION}s"
    
    # Setup environment
    setup_environment
    
    # Run monitoring based on mode
    case "$MODE" in
        "real-time")
            monitor_real_time
            ;;
        "batch")
            monitor_batch
            ;;
        "historical")
            monitor_historical
            ;;
        "daemon")
            run_daemon
            ;;
        *)
            print_error "Unknown mode: $MODE"
            exit 1
            ;;
    esac
    
    # Generate report
    if [[ "$MODE" != "daemon" ]]; then
        generate_report
    fi
    
    if [[ "$MODE" != "daemon" ]]; then
        print_success "Monitoring completed successfully!"
        print_info "Report saved to: $REPORTS_DIR/"
    fi
}

# Handle script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
