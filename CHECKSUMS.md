# 📦 Bun.app v2.0.1 - Checksum Verification

## 🔒 Security Verification

Verify the integrity of downloaded files using these SHA256 checksums.

## 📋 Platform Packages

### 🍎 macOS Package
**File**: `bun-app-macos-2.0.1.tar.gz`  
**Size**: 1,053,253 bytes (1.05 MB)  
**SHA256**: `753251c87239b1a9992ea352c17d417e154bdb9c25d89465d25d9908d74ec8c7`

```bash
# Verify checksum
sha256sum bun-app-macos-2.0.1.tar.gz
# Expected: 753251c87239b1a9992ea352c17d417e154bdb9c25d89465d25d9908d74ec8c7
```

### 🪟 Windows Package
**File**: `bun-app-windows-2.0.1.zip`  
**Size**: 131,339 bytes (131 KB)  
**SHA256**: `e43caf345fab28fab2403e5dc086ee0f3c24c39084b9a9e50137599ed08dd851`

```bash
# Verify checksum (Windows PowerShell)
Get-FileHash bun-app-windows-2.0.1.zip -Algorithm SHA256
# Expected Hash: e43caf345fab28fab2403e5dc086ee0f3c24c39084b9a9e50137599ed08dd851

# Verify checksum (Git Bash/WSL)
sha256sum bun-app-windows-2.0.1.zip
# Expected: e43caf345fab28fab2403e5dc086ee0f3c24c39084b9a9e50137599ed08dd851
```

### 🐧 Linux Package
**File**: `bun-app-linux-2.0.1.tar.gz`  
**Size**: 116,682 bytes (117 KB)  
**SHA256**: `3b646ab9e93e2fde9b98903bf142732bd8af8eeea6bb13893129f87c30c22092`

```bash
# Verify checksum
sha256sum bun-app-linux-2.0.1.tar.gz
# Expected: 3b646ab9e93e2fde9b98903bf142732bd8af8eeea6bb13893129f87c30c22092
```

### 🌐 Chrome Web App
**File**: `bun-app-chrome-2.0.1.zip`  
**Size**: 8,747 bytes (8.7 KB)  
**SHA256**: `65a371bdf87ab53504bb611824d4968d5c00e6c89ee4690cf84623de1a126f15`

```bash
# Verify checksum
sha256sum bun-app-chrome-2.0.1.zip
# Expected: 65a371bdf87ab53504bb611824d4968d5c00e6c89ee4690cf84623de1a126f15
```

### 📦 Source Code
**File**: `bun-app-source-2.0.1.tar.gz`  
**Size**: 1,092,616 bytes (1.09 MB)  
**SHA256**: `894186cbbb2c95dfb720ff3b76f698f54e5c8de2c54c2b8b45b875270741a164`

```bash
# Verify checksum
sha256sum bun-app-source-2.0.1.tar.gz
# Expected: 894186cbbb2c95dfb720ff3b76f698f54e5c8de2c54c2b8b45b875270741a164
```

## 🔍 Verification Instructions

### macOS/Linux
```bash
# Download and verify
wget https://github.com/brendadeeznuts1111/bun-app/releases/download/v2.0.1/bun-app-macos-2.0.1.tar.gz
sha256sum bun-app-macos-2.0.1.tar.gz

# Compare with expected checksum
echo "753251c87239b1a9992ea352c17d417e154bdb9c25d89465d25d9908d74ec8c7  bun-app-macos-2.0.1.tar.gz" | sha256sum -c
```

### Windows (PowerShell)
```powershell
# Download and verify
Invoke-WebRequest -Uri "https://github.com/brendadeeznuts1111/bun-app/releases/download/v2.0.1/bun-app-windows-2.0.1.zip" -OutFile "bun-app-windows-2.0.1.zip"
Get-FileHash bun-app-windows-2.0.1.zip -Algorithm SHA256

# Expected: e43caf345fab28fab2403e5dc086ee0f3c24c39084b9a9e50137599ed08dd851
```

## ⚠️ Security Notes

- Always verify checksums before installation
- Download only from official GitHub releases
- Report any checksum mismatches immediately
- Keep downloaded files secure until verified

## 🔗 Download Sources

- **Official Releases**: https://github.com/brendadeeznuts1111/bun-app/releases
- **Direct Download**: https://github.com/brendadeeznuts1111/bun-app/releases/tag/v2.0.1
- **Security Issues**: https://github.com/brendadeeznuts1111/bun-app/security

---

**📅 Generated**: January 19, 2026  
**🔒 Algorithm**: SHA256  
**📦 Version**: v2.0.1  
**🌐 Platform**: Cross-platform (macOS, Windows, Linux, Chrome)
