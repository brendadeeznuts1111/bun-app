#!/bin/bash

# Test suite for Bun.app functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
APP_PATH="../Bun.app"
TEST_URL="https://bun.com"
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test utility functions
print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
    ((TOTAL_TESTS++))
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_fail "Tests must be run on macOS"
        exit 1
    fi
    
    # Check if Chrome is installed
    if [[ ! -d "/Applications/Google Chrome.app" ]] && [[ ! -d "$HOME/Applications/Google Chrome.app" ]]; then
        print_fail "Google Chrome not found"
        exit 1
    fi
    
    print_info "Dependencies satisfied"
}

# Test functions
test_app_exists() {
    print_test "App bundle exists"
    if [[ -d "$APP_PATH" ]]; then
        print_pass "App bundle found at $APP_PATH"
    else
        print_fail "App bundle not found at $APP_PATH"
        return 1
    fi
}

test_app_structure() {
    print_test "App bundle structure validation"
    
    local required_dirs=(
        "$APP_PATH/Contents"
        "$APP_PATH/Contents/MacOS"
        "$APP_PATH/Contents/Resources"
        "$APP_PATH/Contents/_CodeSignature"
    )
    
    local required_files=(
        "$APP_PATH/Contents/Info.plist"
        "$APP_PATH/Contents/MacOS/app_mode_loader"
        "$APP_PATH/Contents/PkgInfo"
        "$APP_PATH/Contents/Resources/app.icns"
    )
    
    local structure_valid=true
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_fail "Missing directory: $dir"
            structure_valid=false
        fi
    done
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_fail "Missing file: $file"
            structure_valid=false
        fi
    done
    
    if [[ "$structure_valid" == true ]]; then
        print_pass "App bundle structure is valid"
    else
        print_fail "App bundle structure is invalid"
        return 1
    fi
}

test_info_plist() {
    print_test "Info.plist validation"
    
    # Check if Info.plist is valid XML
    if plutil -lint "$APP_PATH/Contents/Info.plist" >/dev/null 2>&1; then
        print_pass "Info.plist is valid XML"
    else
        print_fail "Info.plist is invalid XML"
        return 1
    fi
    
    # Check for required keys
    local required_keys=(
        "CFBundleIdentifier"
        "CFBundleName"
        "CrAppModeShortcutURL"
        "CFBundleExecutable"
    )
    
    local keys_valid=true
    
    for key in "${required_keys[@]}"; do
        if ! plutil -p "$APP_PATH/Contents/Info.plist" | grep -q "$key"; then
            print_fail "Missing key in Info.plist: $key"
            keys_valid=false
        fi
    done
    
    # Check if URL is correct
    local url=$(plutil -p "$APP_PATH/Contents/Info.plist" | grep "CrAppModeShortcutURL" | cut -d'"' -f4)
    if [[ "$url" == "$TEST_URL" ]]; then
        print_pass "Correct URL configured: $url"
    else
        print_fail "Incorrect URL: $url (expected: $TEST_URL)"
        keys_valid=false
    fi
    
    if [[ "$keys_valid" == true ]]; then
        print_pass "Info.plist contains all required keys and correct values"
    else
        print_fail "Info.plist validation failed"
        return 1
    fi
}

test_executable_permissions() {
    print_test "Executable permissions"
    
    if [[ -x "$APP_PATH/Contents/MacOS/app_mode_loader" ]]; then
        print_pass "app_mode_loader has executable permissions"
    else
        print_fail "app_mode_loader lacks executable permissions"
        return 1
    fi
    
    # Check file size (should be reasonable)
    local size=$(stat -f%z "$APP_PATH/Contents/MacOS/app_mode_loader")
    if [[ $size -gt 1000000 ]]; then  # > 1MB
        print_pass "app_mode_loader has reasonable size: $((size/1024/1024))MB"
    else
        print_fail "app_mode_loader seems too small: $size bytes"
        return 1
    fi
}

test_code_signature() {
    print_test "Code signature validation"
    
    if codesign -v "$APP_PATH" 2>/dev/null; then
        print_pass "App has valid code signature"
    else
        print_warning "App lacks valid code signature (expected for development)"
    fi
    
    # Check if code signature file exists
    if [[ -f "$APP_PATH/Contents/_CodeSignature/CodeResources" ]]; then
        print_pass "Code signature file exists"
    else
        print_warning "Code signature file missing (expected for development)"
    fi
}

test_app_launch() {
    print_test "App launch capability"
    
    # Try to launch the app (non-blocking)
    local start_time=$(date +%s)
    
    if open "$APP_PATH"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $duration -lt 10 ]]; then
            print_pass "App launched successfully in ${duration}s"
        else
            print_warning "App launch took longer than expected: ${duration}s"
        fi
        
        # Wait a moment for the app to start
        sleep 3
        
        # Check if app process is running
        local app_name=$(basename "$APP_PATH" .app)
        if pgrep -f "$app_name" > /dev/null; then
            print_pass "App process is running"
            
            # Clean up - quit the app
            osascript -e "quit app \"$app_name\"" 2>/dev/null || true
            sleep 2
            
            # Force kill if still running
            pkill -f "$app_name" 2>/dev/null || true
        else
            print_warning "App process not found after launch (may be normal in CI)"
        fi
    else
        print_fail "Failed to launch app"
        return 1
    fi
}

test_memory_usage() {
    print_test "Memory usage assessment"
    
    # Launch app in background
    open "$APP_PATH"
    sleep 5
    
    # Get memory usage
    local app_name=$(basename "$APP_PATH" .app)
    local memory_usage=$(ps aux | grep "$app_name" | grep -v grep | awk '{sum+=$6} END {print sum/1024}' 2>/dev/null || echo "0")
    
    if (( $(echo "$memory_usage > 0" | bc -l) )); then
        if (( $(echo "$memory_usage < 100" | bc -l) )); then
            print_pass "Memory usage is reasonable: ${memory_usage}MB"
        else
            print_warning "High memory usage: ${memory_usage}MB"
        fi
    else
        print_warning "Could not measure memory usage (app may not be running)"
    fi
    
    # Clean up
    pkill -f "$app_name" 2>/dev/null || true
}

test_network_connectivity() {
    print_test "Network connectivity to target URL"
    
    # Check if the target URL is accessible
    if curl -s -o /dev/null -w "%{http_code}" "$TEST_URL" | grep -q "200"; then
        print_pass "Target URL is accessible: $TEST_URL"
    else
        print_fail "Target URL is not accessible: $TEST_URL"
        return 1
    fi
}

test_security_permissions() {
    print_test "Security permissions"
    
    # Check if app has appropriate permissions
    local permissions=$(ls -la "$APP_PATH/Contents/MacOS/app_mode_loader" | cut -d' ' -f1)
    
    if [[ "$permissions" == *"x"* ]]; then
        print_pass "App has execute permissions"
    else
        print_fail "App lacks execute permissions"
        return 1
    fi
    
    # Check for potentially dangerous permissions
    if [[ "$permissions" == *"w"* ]]; then
        print_warning "App has write permissions (may be security concern)"
    fi
}

test_icon_resources() {
    print_test "Icon resources"
    
    if [[ -f "$APP_PATH/Contents/Resources/app.icns" ]]; then
        local icon_size=$(stat -f%z "$APP_PATH/Contents/Resources/app.icns")
        if [[ $icon_size -gt 1000 ]]; then
            print_pass "Icon file exists and has reasonable size: $icon_size bytes"
        else
            print_warning "Icon file seems too small: $icon_size bytes"
        fi
    else
        print_fail "Icon file missing"
        return 1
    fi
}

test_localization() {
    print_test "Localization resources"
    
    if [[ -f "$APP_PATH/Contents/Resources/en-US.lproj/InfoPlist.strings" ]]; then
        print_pass "Localization file exists"
        
        # Check if it contains expected content
        if grep -q "CFBundleName" "$APP_PATH/Contents/Resources/en-US.lproj/InfoPlist.strings"; then
            print_pass "Localization file contains expected keys"
        else
            print_warning "Localization file may be incomplete"
        fi
    else
        print_warning "Localization file missing (app may still function)"
    fi
}

test_bundle_identifier() {
    print_test "Bundle identifier format"
    
    local bundle_id=$(plutil -p "$APP_PATH/Contents/Info.plist" | grep "CFBundleIdentifier" | cut -d'"' -f4)
    
    if [[ "$bundle_id" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        print_pass "Bundle identifier has valid format: $bundle_id"
    else
        print_fail "Bundle identifier has invalid format: $bundle_id"
        return 1
    fi
    
    # Check if it's unique (not a system bundle ID)
    if [[ "$bundle_id" =~ ^com\.apple\. ]]; then
        print_fail "Bundle identifier conflicts with Apple system IDs"
        return 1
    else
        print_pass "Bundle identifier doesn't conflict with system IDs"
    fi
}

test_version_consistency() {
    print_test "Version consistency"
    
    local chrome_version=$(plutil -p "$APP_PATH/Contents/Info.plist" | grep "CrBundleVersion" | cut -d'"' -f4)
    local bundle_version=$(plutil -p "$APP_PATH/Contents/Info.plist" | grep "CFBundleVersion" | cut -d'"' -f4)
    
    if [[ -n "$chrome_version" && -n "$bundle_version" ]]; then
        print_pass "Version information present: Chrome $chrome_version, Bundle $bundle_version"
    else
        print_warning "Version information incomplete"
    fi
}

# Run all tests
run_tests() {
    echo "🧪 Running Bun.app Functionality Tests"
    echo "====================================="
    
    check_dependencies
    
    # Run individual tests
    test_app_exists
    test_app_structure
    test_info_plist
    test_executable_permissions
    test_code_signature
    test_app_launch
    test_memory_usage
    test_network_connectivity
    test_security_permissions
    test_icon_resources
    test_localization
    test_bundle_identifier
    test_version_consistency
    
    # Print results
    echo ""
    echo "📊 Test Results"
    echo "==============="
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n🎉 ${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "\n❌ ${RED}Some tests failed.${NC}"
        return 1
    fi
}

# Handle command line arguments
case "${1:-all}" in
    "all")
        run_tests
        ;;
    "structure")
        check_dependencies
        test_app_exists
        test_app_structure
        ;;
    "security")
        check_dependencies
        test_security_permissions
        test_code_signature
        test_bundle_identifier
        ;;
    "functionality")
        check_dependencies
        test_app_launch
        test_memory_usage
        test_network_connectivity
        ;;
    "help")
        echo "Usage: $0 [all|structure|security|functionality|help]"
        echo "  all         - Run all tests (default)"
        echo "  structure   - Test app bundle structure"
        echo "  security    - Test security features"
        echo "  functionality- Test app functionality"
        echo "  help        - Show this help"
        ;;
    *)
        echo "Unknown test suite: $1"
        echo "Use '$0 help' for available options"
        exit 1
        ;;
esac
