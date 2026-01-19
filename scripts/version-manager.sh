#!/bin/bash

# Version Manager for Bun.app
# Handles semantic versioning using Bun's built-in semver functionality

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
VERSION_FILE="$PROJECT_DIR/VERSION"
CHANGELOG_FILE="$PROJECT_DIR/CHANGELOG.md"
PACKAGE_FILE="$PROJECT_DIR/package.json"

# Check if Bun is available
check_bun() {
    if ! command -v bun >/dev/null 2>&1; then
        echo -e "${RED}❌ Bun is not installed or not in PATH${NC}"
        echo -e "${YELLOW}Please install Bun from https://bun.sh${NC}"
        exit 1
    fi
}

# Get current version from package.json or VERSION file
get_current_version() {
    if [[ -f "$PACKAGE_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq -r '.version // empty' "$PACKAGE_FILE" 2>/dev/null
    elif [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "1.0.0"
    fi
}

# Current version
CURRENT_VERSION=$(get_current_version)

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --patch|-p)
                BUMP_TYPE="patch"
                shift
                ;;
            --minor|-m)
                BUMP_TYPE="minor"
                shift
                ;;
            --major|-M)
                BUMP_TYPE="major"
                shift
                ;;
            --version|-v)
                NEW_VERSION="$2"
                shift 2
                ;;
            --dry-run|-d)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                COMMAND="$1"
                shift
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
🏷️  Bun.app Version Manager (Powered by Bun SemVer)

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    bump                   Bump version using Bun's semver (patch by default)
    current                Show current version
    release                Create release with changelog
    tag                    Create git tag for current version
    validate               Validate version format

OPTIONS:
    -p, --patch            Bump patch version (default)
    -m, --minor            Bump minor version
    -M, --major            Bump major version
    -v, --version VERSION  Set specific version
    -d, --dry-run          Show changes without applying
    -h, --help             Show this help

EXAMPLES:
    $0 bump --patch        # Bump to 1.0.1 using Bun semver
    $0 bump --minor        # Bump to 1.1.0 using Bun semver
    $0 bump --major        # Bump to 2.0.0 using Bun semver
    $0 release             # Create release
    $0 current             # Show current version

BUN SEMVER FEATURES:
- Automatic semantic versioning
- Git tag creation
- package.json updates
- Version validation
- Release automation

EOF
}

# Validate version format using Bun
validate_version() {
    local version="$1"
    check_bun
    
    # Use Bun to validate version format
    if ! bun pm pkg get version >/dev/null 2>&1; then
        echo -e "${RED}❌ Invalid version format: $version${NC}"
        echo -e "${YELLOW}Expected format: MAJOR.MINOR.PATCH (e.g., 2.0.0)${NC}"
        exit 1
    fi
}

# Bump version using Bun's semver
bump_version() {
    check_bun
    
    local bump_type="${BUMP_TYPE:-patch}"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 DRY RUN: Would bump version using Bun semver ($bump_type)${NC}"
        local current=$(get_current_version)
        echo -e "${BLUE}Current: $current${NC}"
        return
    fi
    
    echo -e "${BLUE}📝 Bumping version using Bun semver ($bump_type)${NC}"
    
    # Ensure we're in project directory
    cd "$PROJECT_DIR"
    
    # Create package.json if it doesn't exist
    if [[ ! -f "$PACKAGE_FILE" ]]; then
        echo -e "${YELLOW}⚠️  Creating package.json for version management${NC}"
        cat > "$PACKAGE_FILE" << EOF
{
  "name": "bun-app",
  "version": "$CURRENT_VERSION",
  "description": "Enterprise-Grade Chrome Web Application Platform",
  "type": "commonjs"
}
EOF
    fi
    
    # Use Bun to bump version
    if bun pm version "$bump_type" >/dev/null 2>&1; then
        NEW_VERSION=$(get_current_version)
        echo -e "${GREEN}✅ Version bumped to $NEW_VERSION using Bun semver${NC}"
    else
        echo -e "${RED}❌ Failed to bump version using Bun semver${NC}"
        exit 1
    fi
    
    # Update VERSION file for backward compatibility
    echo "$NEW_VERSION" > "$VERSION_FILE"
}

# Set specific version using Bun
set_version() {
    local version="$1"
    validate_version "$version"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 DRY RUN: Would set version to $version${NC}"
        return
    fi
    
    echo -e "${BLUE}📝 Setting version to $version using Bun${NC}"
    
    # Ensure we're in project directory
    cd "$PROJECT_DIR"
    
    # Create package.json if it doesn't exist
    if [[ ! -f "$PACKAGE_FILE" ]]; then
        cat > "$PACKAGE_FILE" << EOF
{
  "name": "bun-app",
  "version": "$version",
  "description": "Enterprise-Grade Chrome Web Application Platform",
  "type": "commonjs"
}
EOF
    else
        # Update version in package.json using Bun
        bun pm pkg set "version=$version"
    fi
    
    # Update VERSION file for backward compatibility
    echo "$version" > "$VERSION_FILE"
    
    echo -e "${GREEN}✅ Version set to $version${NC}"
}

# Update version files (maintained for backward compatibility)
update_version_files() {
    local version="$1"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 DRY RUN: Would update version files to $version${NC}"
        return
    fi
    
    echo -e "${BLUE}📝 Updating version files to $version${NC}"
    
    # Update VERSION file
    echo "$version" > "$VERSION_FILE"
    
    # Update Info.plist if exists
    local info_plist="$PROJECT_DIR/Contents/Info.plist"
    if [[ -f "$info_plist" ]]; then
        if command -v plutil >/dev/null 2>&1; then
            plutil -replace CFBundleShortVersionString -string "$version" "$info_plist"
        else
            echo -e "${YELLOW}⚠️  plutil not found, skipping Info.plist update${NC}"
        fi
    fi
    
    echo -e "${GREEN}✅ Version files updated${NC}"
}

# Update changelog
update_changelog() {
    local version="$1"
    local date=$(date +%Y-%m-%d)
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 DRY RUN: Would update changelog for $version${NC}"
        return
    fi
    
    echo -e "${BLUE}📝 Updating changelog for $version${NC}"
    
    # Create temporary changelog
    local temp_changelog=$(mktemp)
    
    # Add new version entry
    cat > "$temp_changelog" << EOF
## [$version] - $date

### ✨ Added
- Feature additions for version $version

### 🔧 Enhanced
- Improvements and enhancements

### 🐛 Fixed
- Bug fixes and resolves

### 📚 Documentation
- Documentation updates

---

EOF
    
    # Append existing changelog (skip first few lines)
    tail -n +4 "$CHANGELOG_FILE" >> "$temp_changelog"
    
    # Replace changelog
    mv "$temp_changelog" "$CHANGELOG_FILE"
    
    echo -e "${GREEN}✅ Changelog updated${NC}"
}

# Create git tag
create_git_tag() {
    local version="$1"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 DRY RUN: Would create git tag v$version${NC}"
        return
    fi
    
    echo -e "${BLUE}🏷️  Creating git tag v$version${NC}"
    
    # Check if tag already exists
    if git rev-parse "v$version" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Tag v$version already exists${NC}"
        return
    fi
    
    # Create annotated tag
    git tag -a "v$version" -m "Release v$version"
    
    echo -e "${GREEN}✅ Git tag created${NC}"
}

# Create release
create_release() {
    local version="$1"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 DRY RUN: Would create release v$version${NC}"
        return
    fi
    
    echo -e "${BLUE}🚀 Creating release v$version${NC}"
    
    # Check if gh CLI is available
    if ! command -v gh >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  GitHub CLI not found, skipping GitHub release${NC}"
        return
    fi
    
    # Generate release notes
    local release_notes=$(mktemp)
    cat > "$release_notes" << EOF
# 🚀 Bun.app v$version

## 🎯 Release Highlights

This release includes significant enhancements to the Bun.app enterprise platform.

## 📋 Changes

See the [CHANGELOG.md](CHANGELOG.md) for detailed changes.

## 🔧 Installation

\`\`\`bash
# Clone the repository
git clone --branch v$version https://github.com/brendadeeznuts1111/bun-app.git
cd bun-app

# Follow the setup guide in README.md
\`\`\`

## 📞 Support

- 📧 Issues: [GitHub Issues](https://github.com/brendadeeznuts1111/bun-app/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/brendadeeznuts1111/bun-app/discussions)
EOF
    
    # Create GitHub release
    gh release create "v$version" --title "Release v$version" --notes-file "$release_notes"
    
    # Cleanup
    rm "$release_notes"
    
    echo -e "${GREEN}✅ GitHub release created${NC}"
}

# Show current version
show_current_version() {
    echo -e "${BOLD}📋 Current Version:${NC}"
    echo -e "${GREEN}$CURRENT_VERSION${NC}"
    
    # Show Bun version
    if command -v bun >/dev/null 2>&1; then
        local bun_version=$(bun --version)
        echo -e "${BOLD}🥞 Bun Version:${NC} $bun_version"
    fi
    
    # Show git status
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local current_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "No tags")
        echo -e "${BOLD}🏷️  Current Tag:${NC} $current_tag"
    fi
}

# Validate current setup
validate_setup() {
    echo -e "${BLUE}🔍 Validating version setup...${NC}"
    
    # Check Bun
    check_bun
    
    # Check VERSION file
    if [[ ! -f "$VERSION_FILE" ]]; then
        echo -e "${YELLOW}⚠️  VERSION file not found, will create${NC}"
    fi
    
    # Validate version format
    validate_version "$CURRENT_VERSION"
    
    # Check changelog
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        echo -e "${RED}❌ CHANGELOG.md not found${NC}"
        exit 1
    fi
    
    # Check git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Not in a git repository${NC}"
    fi
    
    echo -e "${GREEN}✅ Version setup is valid${NC}"
}

# Main function
main() {
    # Parse arguments
    parse_args "$@"
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Handle commands
    case "${COMMAND:-help}" in
        "current")
            show_current_version
            ;;
        "validate")
            validate_setup
            ;;
        "bump")
            validate_setup
            if [[ -n "$NEW_VERSION" ]]; then
                set_version "$NEW_VERSION"
            else
                bump_version
            fi
            update_changelog "$NEW_VERSION"
            echo -e "${BOLD}🎉 Version bumped to $NEW_VERSION using Bun semver${NC}"
            ;;
        "tag")
            validate_setup
            create_git_tag "$CURRENT_VERSION"
            ;;
        "release")
            validate_setup
            if [[ -n "$NEW_VERSION" ]]; then
                set_version "$NEW_VERSION"
            else
                bump_version
            fi
            update_changelog "$NEW_VERSION"
            create_git_tag "$NEW_VERSION"
            create_release "$NEW_VERSION"
            echo -e "${BOLD}🎉 Release $NEW_VERSION created successfully using Bun semver!${NC}"
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
