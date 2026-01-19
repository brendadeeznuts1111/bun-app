# Contributing to Bun.app

Thank you for your interest in contributing to Bun.app! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Getting Started

1. **Fork the Repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/yourusername/bun-app.git
   cd bun-app
   ```

2. **Set Up Development Environment**
   ```bash
   # Add upstream remote
   git remote add upstream https://github.com/brendadeeznuts1111/bun-app.git
   
   # Create a development branch
   git checkout -b feature/your-feature-name
   ```

3. **Install Dependencies**
   ```bash
   # Ensure Chrome is installed
   which google-chrome-stable || which chrome
   
   # Make build script executable
   chmod +x build.sh
   ```

### Types of Contributions

We welcome the following types of contributions:

- 🐛 **Bug Fixes**: Fix issues with the app bundle or build process
- ✨ **New Features**: Add functionality to the build script or app
- 📚 **Documentation**: Improve README, guides, and comments
- 🧪 **Testing**: Add or improve tests
- 🎨 **Design**: Improve UI/UX or add new icons
- 🔧 **Tooling**: Improve build processes and automation

### Development Workflow

1. **Make Changes**
   - Follow existing code style and conventions
   - Add comments for complex logic
   - Update relevant documentation

2. **Test Your Changes**
   ```bash
   # Test the build script
   ./build.sh "https://example.com" "TestApp"
   
   # Verify the app works
   open TestApp.app
   ```

3. **Commit Your Changes**
   ```bash
   # Stage your changes
   git add .
   
   # Commit with a descriptive message
   git commit -m "feat: add new feature description"
   ```

4. **Push and Create Pull Request**
   ```bash
   # Push to your fork
   git push origin feature/your-feature-name
   
   # Create a pull request on GitHub
   ```

## 📝 Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```bash
feat(build): add custom icon support
fix(app): resolve Chrome version compatibility issue
docs(readme): update installation instructions
test(ci): add build script validation
```

## 🧪 Testing Guidelines

### Running Tests

```bash
# Run the build script tests
./build.sh "https://github.com" "GitHubTest"

# Test app functionality
open GitHubTest.app

# Clean up test apps
rm -rf GitHubTest.app
```

### Test Coverage

- **Build Script**: Test with various URLs and names
- **App Bundle**: Verify structure and permissions
- **Chrome Integration**: Test app mode functionality
- **Documentation**: Validate links and formatting

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] Correct URL loads in app mode
- [ ] No browser UI elements visible
- [ ] App quits properly (⌘+Q)
- [ ] Icon displays correctly
- [ ] Memory usage is reasonable (<100MB)

## 📋 Code Style Guidelines

### Shell Script (build.sh)
- Use 4 spaces for indentation
- Quote variables: `"$VAR"` instead of `$VAR`
- Use `[[ ]]` for conditional tests
- Add comments for complex logic
- Use meaningful function names

### Documentation
- Use clear, concise language
- Include code examples with syntax highlighting
- Add screenshots where appropriate
- Maintain consistent formatting

### File Organization
```
bun-app/
├── .github/
│   ├── workflows/     # CI/CD configurations
│   ├── ISSUE_TEMPLATE/ # Issue templates
│   └── PULL_REQUEST_TEMPLATE.md
├── Contents/          # App bundle
├── docs/             # Additional documentation
├── tests/            # Test files
├── scripts/          # Utility scripts
├── README.md         # Main documentation
├── CONTRIBUTING.md   # This file
├── LICENSE           # License file
└── build.sh          # Build script
```

## 🐛 Bug Reports

### Before Creating a Bug Report

1. **Check existing issues** for similar problems
2. **Test with the latest version**
3. **Ensure your environment meets requirements**
   - macOS 12.0+
   - Latest Google Chrome

### Creating a Bug Report

Use the [Bug Report Template](.github/ISSUE_TEMPLATE/bug_report.md) and include:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Detailed reproduction steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: macOS version, Chrome version, etc.
- **Screenshots**: If applicable

## ✨ Feature Requests

### Requesting New Features

1. **Check existing issues** for similar requests
2. **Use the Feature Request Template**
3. **Provide clear use case** and benefits
4. **Consider implementation complexity**

### Feature Request Criteria

- **Alignment**: Fits project goals
- **Demand**: Benefits multiple users
- **Feasibility**: Technically possible
- **Maintenance**: Long-term sustainability

## 🔍 Code Review Process

### Reviewer Guidelines

- **Check functionality**: Does it work as intended?
- **Verify tests**: Are tests included and passing?
- **Review documentation**: Is documentation updated?
- **Check style**: Does it follow project guidelines?
- **Security**: Are there security implications?

### Author Guidelines

- **Respond promptly** to review comments
- **Address all feedback** before requesting another review
- **Update documentation** as needed
- **Add tests** for new functionality

## 📦 Release Process

### Release Checklist

- [ ] All tests pass
- [ ] Documentation is updated
- [ ] CHANGELOG is updated
- [ ] Version is bumped
- [ ] Release notes are prepared
- [ ] CI/CD pipeline passes

### Versioning

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## 🏆 Recognition

### Contributors

All contributors are recognized in:
- **README.md**: Contributors section
- **Release Notes**: For each release
- **GitHub Statistics**: Automatic tracking

### Ways to Contribute

- **Code**: Patches and new features
- **Documentation**: Improvements and translations
- **Testing**: Bug reports and test cases
- **Design**: Icons, screenshots, UI improvements
- **Community**: Support and discussions

## 📞 Getting Help

### Resources

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For general questions
- **Documentation**: README and other docs
- **Code Comments**: Inline documentation

### Contact

- **Maintainers**: @brendadeeznuts1111
- **Community**: GitHub Discussions
- **Issues**: GitHub Issues

## 📜 Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please read our [Code of Conduct](CODE_OF_CONDUCT.md) and follow it in all interactions.

## 🎯 Project Goals

Our mission is to:

1. **Provide easy access** to bun.com via a native macOS app
2. **Maintain high quality** documentation and code
3. **Support the community** with helpful tools and resources
4. **Follow best practices** for open source development
5. **Ensure security** and privacy for all users

---

Thank you for contributing to Bun.app! Your help makes this project better for everyone. 🚀
