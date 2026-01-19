#!/bin/bash

# Version Manager for Bun.app
# Handles semantic versioning, changelog updates, and releases

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

# Current version
CURRENT_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")

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
🏷️  Bun.app Version Manager

USAGE:
    $0 [OPTIONS] <COMMAND>

COMMANDS:
    bump                   Bump version (patch by default)
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
    $0 bump --patch        # Bump to 1.0.1
    $0 bump --minor        # Bump to 1.1.0
    $0 bump --major        # Bump to 2.0.0
    $0 release             # Create release
    $0 current             # Show current version

VERSION FORMAT:
    Follows Semantic Versioning: MAJOR.MINOR.PATCH
    - MAJOR: Incompatible API changes
    - MINOR: New functionality (backwards compatible)
    - PATCH: Bug fixes (backwards compatible)

EOF
}

# Validate version format
validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid version format: $version${NC}"
        echo -e "${YELLOW}Expected format: MAJOR.MINOR.PATCH (e.g., 2.0.0)${NC}"
        exit 1
    fi
}

# Bump version based on type
bump_version() {
    local bump_type="${BUMP_TYPE:-patch}"
    local version="$CURRENT_VERSION"
    
    # Parse current version
    IFS='.' read -ra PARTS <<< "$version"
    local major="${PARTS[0]}"
    local minor="${PARTS[1]}"
    local patch="${PARTS[2]}"
    
    case "$bump_type" in
        "patch")
            patch=$((patch + 1))
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        *)
            echo -e "${RED}❌ Invalid bump type: $bump_type${NC}"
            exit 1
            ;;
    esac
    
    NEW_VERSION="$major.$minor.$patch"
    validate_version "$NEW_VERSION"
}

# Update version files
update_version_files() {
    local version="$1"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 DRY RUN: Would update version to $version${NC}"
        return
    fi
    
    echo -e "${BLUE}📝 Updating version files to $version${NC}"
    
    # Update VERSION file
    echo "$version" > "$VERSION_FILE"
    
    # Update package.json if exists
    if [[ -f "$PACKAGE_FILE" ]]; then
        if command -v jq >/dev/null 2>&1; then
            jq --arg version "$version" '.version = $version' "$PACKAGE_FILE" > "$PACKAGE_FILE.tmp"
            mv "$PACKAGE_FILE.tmp" "$PACKAGE_FILE"
        else
            echo -e "${YELLOW}⚠️  jq not found, skipping package.json update${NC}"
        fi
    fi
    
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
    
    # Show git status
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local current_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "No tags")
        echo -e "${BOLD}🏷️  Current Tag:${NC} $current_tag"
    fi
}

# Validate current setup
validate_setup() {
    echo -e "${BLUE}🔍 Validating version setup...${NC}"
    
    # Check VERSION file
    if [[ ! -f "$VERSION_FILE" ]]; then
        echo -e "${RED}❌ VERSION file not found${NC}"
        exit 1
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
            if [[ -z "$NEW_VERSION" ]]; then
                bump_version
            else
                validate_version "$NEW_VERSION"
            fi
            update_version_files "$NEW_VERSION"
            update_changelog "$NEW_VERSION"
            echo -e "${BOLD}🎉 Version bumped to $NEW_VERSION${NC}"
            ;;
        "tag")
            validate_setup
            create_git_tag "$CURRENT_VERSION"
            ;;
        "release")
            validate_setup
            update_version_files "$CURRENT_VERSION"
            update_changelog "$CURRENT_VERSION"
            create_git_tag "$CURRENT_VERSION"
            create_release "$CURRENT_VERSION"
            echo -e "${BOLD}🎉 Release $CURRENT_VERSION created successfully!${NC}"
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
