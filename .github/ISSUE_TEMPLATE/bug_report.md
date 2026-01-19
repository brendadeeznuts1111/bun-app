---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: 'bug'
assignees: ''

---

## 🐛 Bug Description

A clear and concise description of what the bug is.

## 🔄 Reproduction Steps

Detailed steps to reproduce the behavior:

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## ✅ Expected Behavior

A clear and concise description of what you expected to happen.

## ❌ Actual Behavior

A clear and concise description of what actually happened.

## 📱 Environment Information

**Please complete the following information:**

- **macOS Version**: [e.g. macOS 13.0 Ventura]
- **Chrome Version**: [e.g. 119.0.6045.123]
- **App Version**: [e.g. 1.0.0 or commit hash]
- **Architecture**: [e.g. Intel, Apple Silicon M1/M2]

### Installation Method

- [ ] Cloned from repository
- [ ] Downloaded release
- [ ] Built from source
- [ ] Other: please specify

## 📋 Additional Context

Add any other context about the problem here.

## 🖼️ Screenshots

If applicable, add screenshots to help explain your problem.

## 📊 Console Logs

Please provide any relevant console logs or error messages:

```bash
# Paste console output here
```

## 🔍 Debug Information

Run the following commands and provide the output:

```bash
# Check app structure
ls -la Bun.app/Contents/

# Check Info.plist
plutil -p Bun.app/Contents/Info.plist

# Check permissions
ls -la Bun.app/Contents/MacOS/

# Check for running processes
ps aux | grep Bun.app
```

## 🛠️ Troubleshooting Steps Taken

What have you tried to resolve this issue?

- [ ] Restarted the app
- [ ] Reinstalled the app
- [ ] Updated Chrome
- [ ] Updated macOS
- [ ] Tried building from source
- [ ] Other: please specify

## ✅ Checklist

- [ ] I have searched existing issues for similar problems
- [ ] I have provided all requested environment information
- [ ] I have included relevant logs and error messages
- [ ] I have followed the troubleshooting steps
- [ ] I am using the latest version of the app

## 📞 Additional Information

Is there anything else we should know about this issue?
