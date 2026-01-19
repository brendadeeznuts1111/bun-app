#!/bin/bash

# Test suite for Bun.app build script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="test_output"
BUILD_SCRIPT="../build.sh"
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

# Setup and cleanup
setup() {
    print_info "Setting up test environment..."
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Copy build script
    cp "../$BUILD_SCRIPT" .
    chmod +x build.sh
    
    # Check if Chrome is available
    if [[ ! -d "/Applications/Google Chrome.app" ]] && [[ ! -d "$HOME/Applications/Google Chrome.app" ]]; then
        print_info "Chrome not found, installing..."
        brew install --cask google-chrome 2>/dev/null || true
    fi
}

cleanup() {
    print_info "Cleaning up test environment..."
    cd ..
    rm -rf "$TEST_DIR"
}

# Test functions
test_build_script_exists() {
    print_test "Build script exists and is executable"
    if [[ -f "build.sh" && -x "build.sh" ]]; then
        print_pass "Build script exists and is executable"
    else
        print_fail "Build script missing or not executable"
        return 1
    fi
}

test_default_build() {
    print_test "Default build (bun.com)"
    if ./build.sh; then
        if [[ -d "Bun.app" ]]; then
            print_pass "Default build successful"
            rm -rf "Bun.app"
        else
            print_fail "Bun.app not created"
            return 1
        fi
    else
        print_fail "Default build failed"
        return 1
    fi
}

test_custom_url_build() {
    print_test "Custom URL build"
    if ./build.sh "https://github.com" "GitHub"; then
        if [[ -d "GitHub.app" ]]; then
            print_pass "Custom URL build successful"
            rm -rf "GitHub.app"
        else
            print_fail "GitHub.app not created"
            return 1
        fi
    else
        print_fail "Custom URL build failed"
        return 1
    fi
}

test_invalid_url() {
    print_test "Invalid URL handling"
    if ./build.sh "invalid-url" "Test" 2>/dev/null; then
        print_fail "Should have failed with invalid URL"
        return 1
    else
        print_pass "Correctly rejected invalid URL"
    fi
}

test_app_structure() {
    print_test "App bundle structure validation"
    ./build.sh "https://example.com" "TestApp"
    
    local required_dirs=(
        "TestApp.app/Contents"
        "TestApp.app/Contents/MacOS"
        "TestApp.app/Contents/Resources"
        "TestApp.app/Contents/_CodeSignature"
    )
    
    local required_files=(
        "TestApp.app/Contents/Info.plist"
        "TestApp.app/Contents/MacOS/app_mode_loader"
        "TestApp.app/Contents/PkgInfo"
        "TestApp.app/Contents/Resources/app.icns"
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
    
    rm -rf "TestApp.app"
}

test_info_plist() {
    print_test "Info.plist validation"
    ./build.sh "https://test.com" "TestApp"
    
    # Check if Info.plist is valid XML
    if plutil -lint "TestApp.app/Contents/Info.plist" >/dev/null 2>&1; then
        print_pass "Info.plist is valid XML"
    else
        print_fail "Info.plist is invalid XML"
        rm -rf "TestApp.app"
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
        if ! plutil -p "TestApp.app/Contents/Info.plist" | grep -q "$key"; then
            print_fail "Missing key in Info.plist: $key"
            keys_valid=false
        fi
    done
    
    if [[ "$keys_valid" == true ]]; then
        print_pass "Info.plist contains all required keys"
    else
        print_fail "Info.plist missing required keys"
        rm -rf "TestApp.app"
        return 1
    fi
    
    rm -rf "TestApp.app"
}

test_executable_permissions() {
    print_test "Executable permissions"
    ./build.sh "https://test.com" "TestApp"
    
    if [[ -x "TestApp.app/Contents/MacOS/app_mode_loader" ]]; then
        print_pass "app_mode_loader has executable permissions"
    else
        print_fail "app_mode_loader lacks executable permissions"
        rm -rf "TestApp.app"
        return 1
    fi
    
    rm -rf "TestApp.app"
}

test_url_injection() {
    print_test "URL injection prevention"
    # Test for potentially dangerous URLs
    local dangerous_urls=(
        "javascript:alert('xss')"
        "data:text/html,<script>alert('xss')</script>"
        "file:///etc/passwd"
    )
    
    for url in "${dangerous_urls[@]}"; do
        if ./build.sh "$url" "TestApp" 2>/dev/null; then
            print_fail "Should have rejected dangerous URL: $url"
            rm -rf "TestApp.app" 2>/dev/null || true
            return 1
        fi
    done
    
    print_pass "URL injection prevention working"
}

test_name_sanitization() {
    print_test "App name sanitization"
    # Test with problematic names
    local problematic_names=(
        "Test/App"
        "Test..App"
        "Test.App."
        "../../../etc/passwd"
    )
    
    for name in "${problematic_names[@]}"; do
        if ./build.sh "https://test.com" "$name" 2>/dev/null; then
            # Check if app was created with sanitized name
            if [[ -d "*.app" ]]; then
                print_pass "App name sanitized: $name"
                rm -rf *.app
            else
                print_fail "App creation failed for name: $name"
                return 1
            fi
        else
            print_fail "Build failed for name: $name"
            return 1
        fi
    done
}

test_concurrent_builds() {
    print_test "Concurrent build handling"
    ./build.sh "https://test1.com" "TestApp1" &
    local pid1=$!
    
    ./build.sh "https://test2.com" "TestApp2" &
    local pid2=$!
    
    wait $pid1
    local result1=$?
    
    wait $pid2
    local result2=$?
    
    if [[ $result1 -eq 0 && $result2 -eq 0 ]]; then
        if [[ -d "TestApp1.app" && -d "TestApp2.app" ]]; then
            print_pass "Concurrent builds successful"
            rm -rf "TestApp1.app" "TestApp2.app"
        else
            print_fail "One or more apps not created in concurrent build"
            return 1
        fi
    else
        print_fail "One or more concurrent builds failed"
        return 1
    fi
}

test_cleanup_on_failure() {
    print_test "Cleanup on build failure"
    # Create a scenario that should fail
    if ./build.sh "invalid-url" "TestApp" 2>/dev/null; then
        print_fail "Build should have failed"
        return 1
    fi
    
    # Check no partial app was left behind
    if [[ -d "TestApp.app" ]]; then
        print_fail "Partial app left behind after failure"
        rm -rf "TestApp.app"
        return 1
    else
        print_pass "No partial app left after failure"
    fi
}

# Performance test
test_build_performance() {
    print_test "Build performance"
    local start_time=$(date +%s)
    
    if ./build.sh "https://test.com" "TestApp"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $duration -lt 30 ]]; then
            print_pass "Build completed in ${duration}s (under 30s limit)"
        else
            print_fail "Build took too long: ${duration}s"
            rm -rf "TestApp.app"
            return 1
        fi
        
        rm -rf "TestApp.app"
    else
        print_fail "Build failed during performance test"
        return 1
    fi
}

# Run all tests
run_tests() {
    echo "🧪 Running Bun.app Build Script Tests"
    echo "===================================="
    
    setup
    
    # Run individual tests
    test_build_script_exists
    test_default_build
    test_custom_url_build
    test_invalid_url
    test_app_structure
    test_info_plist
    test_executable_permissions
    test_url_injection
    test_name_sanitization
    test_concurrent_builds
    test_cleanup_on_failure
    test_build_performance
    
    cleanup
    
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
        setup
        test_app_structure
        cleanup
        ;;
    "security")
        setup
        test_url_injection
        test_name_sanitization
        cleanup
        ;;
    "performance")
        setup
        test_build_performance
        cleanup
        ;;
    "help")
        echo "Usage: $0 [all|structure|security|performance|help]"
        echo "  all        - Run all tests (default)"
        echo "  structure  - Test app bundle structure"
        echo "  security   - Test security features"
        echo "  performance- Test build performance"
        echo "  help       - Show this help"
        ;;
    *)
        echo "Unknown test suite: $1"
        echo "Use '$0 help' for available options"
        exit 1
        ;;
esac
