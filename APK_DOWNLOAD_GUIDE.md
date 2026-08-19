# 📱 NeRuWallet APK Download & Installation Guide

## 🎯 Quick Start

**⬇️ [Download APK from Build Artifacts](https://github.com/devmilang99/NeRuWallet/actions/runs/32239538812/artifacts/9360559423)**

This document provides complete instructions for downloading and installing the latest NeRuWallet APK build.

---

## 📦 What You're Downloading

You are downloading **NeRuWallet** - a secure and scalable digital payment solution built with:
- **Frontend**: Flutter/Dart (96.5%)
- **Security Layer**: Rust-based cryptographic signing (1.7%)
- **Native Integration**: Kotlin (Android) and Swift (iOS)

This APK is automatically built and packaged from the latest source code via GitHub Actions CI/CD pipeline.

---

## ✅ System Requirements

Before installation, ensure your device meets these requirements:

| Requirement | Specification |
|---|---|
| **Minimum Android Version** | Android 6.0 (API Level 23) |
| **Recommended Android Version** | Android 8.0 or higher |
| **Storage Space** | At least 100MB free |
| **RAM** | Minimum 2GB (4GB+ recommended) |
| **Network** | Internet connection required for transactions |

---

## 🚀 Installation Methods

### Method 1: Direct Installation (Easiest)

1. **Download the APK**
   - Click the download link above to get the APK file
   - Wait for download to complete

2. **Prepare Your Device**
   - Go to: **Settings → Security**
   - Find and toggle on **"Unknown Sources"** or **"Install from Unknown Sources"**
   - (This allows installation from outside Google Play Store)

3. **Install the Application**
   - Open your file manager
   - Navigate to Downloads folder
   - Tap on the `.apk` file
   - Confirm installation when prompted
   - Wait for installation to complete

4. **Launch NeRuWallet**
   - Find the app in your app drawer
   - Tap to open for the first time
   - Grant all requested permissions:
     - ✓ Internet access
     - ✓ Camera (for QR code scanning)
     - ✓ Contacts (for recipient suggestions)
     - ✓ Storage (for transaction history)

### Method 2: Command Line Installation (ADB)

For developers with Android SDK tools installed:

```bash
# Step 1: Connect your Android device via USB
# Enable USB Debugging on device: Settings → Developer Options → USB Debugging
adb devices

# Step 2: Install the APK
adb install path/to/NeRuWallet.apk

# Step 3: Launch the app
adb shell am start -n com.devmilang99.neruwallet/.MainActivity
```

### Method 3: Sideload via Android Studio

1. Open Android Studio
2. Go to: **Tools → Device Manager**
3. Select your emulator/device
4. Go to: **Tools → AVD Manager → Install APK**
5. Select downloaded NeRuWallet APK
6. Wait for installation to complete

---

## 🔒 Security & Permissions

NeRuWallet is built with security as a priority. Here's what the app accesses and why:

| Permission | Purpose |
|---|---|
| **INTERNET** | Connect to payment servers, verify transactions, sync data |
| **CAMERA** | QR code scanning for quick payment recipients |
| **READ_CONTACTS** | Suggest saved contacts as payment recipients |
| **WRITE_EXTERNAL_STORAGE** | Store encrypted transaction backups |
| **READ_PHONE_STATE** | Device identification for security |

**All permissions are:**
- ✓ Explicitly requested at first launch
- ✓ Can be individually denied (with feature limitations)
- ✓ Revocable at any time via Settings

---

## 🐛 Troubleshooting

### Installation Issues

| Problem | Solution |
|---|---|
| **"Installation blocked" message** | Enable "Unknown Sources" in Settings → Security |
| **"Insufficient storage space"** | Free up at least 150MB and retry |
| **"Installation failed" or APK corrupted** | Re-download the APK file (may be incomplete) |
| **"App not installed as package appears invalid"** | Download again - file may be damaged |

### Runtime Issues

| Problem | Solution |
|---|---|
| **App crashes on startup** | Clear app cache: Settings → Apps → NeRuWallet → Storage → Clear Cache |
| **"Permission denied" errors** | Go to Settings → Apps → NeRuWallet → Permissions → Grant missing permissions |
| **Network/sync issues** | Check internet connection and ensure data/WiFi is enabled |
| **Slow performance** | Close background apps, clear cache, or restart device |

### Uninstalling

To completely remove NeRuWallet:
```
Settings → Apps → NeRuWallet → Uninstall
```

---

## 🔄 Updating

When new builds are released:
1. Download the new APK using the link above
2. Install it over the existing version
3. Your data and settings will be preserved
4. App will restart and show update notes

---

## 📊 Build Information

```
Build Type: Release
Build Date: 2026-08-19
Build Number: 32239538812
Artifact ID: 9360559423
Architecture: arm64-v8a, armeabi-v7a, x86, x86_64
Language Composition:
  - Dart: 96.5%
  - Rust (Cryptography): 1.7%
  - Kotlin (Android): 1.0%
  - Swift (iOS): 0.7%
```

---

## 📞 Support & Feedback

### Report Issues
- Found a bug? [Open an issue on GitHub](https://github.com/devmilang99/NeRuWallet/issues)
- Include: Device model, Android version, and error message

### Request Features
- Have an idea? [Create a feature request](https://github.com/devmilang99/NeRuWallet/discussions)

### Get Help
- Check [GitHub Discussions](https://github.com/devmilang99/NeRuWallet/discussions) for common questions
- Review app logs: Settings → About → Send Logs

---

## ⚖️ Terms & Disclaimer

By installing NeRuWallet, you agree to:
- Use this application for lawful purposes only
- Keep your device secure and backups safe
- Comply with local financial regulations
- Report any security vulnerabilities responsibly

**NeRuWallet comes as-is without warranties.** For production use, ensure thorough testing.

---

## 🔐 Security Best Practices

1. **Keep Your Device Updated**
   - Install all Android security patches
   - Keep NeRuWallet updated

2. **Backup Your Data**
   - Regular encrypted backups of your wallet
   - Store recovery phrases securely (offline)

3. **Use Device Security**
   - Enable biometric lock (fingerprint/face)
   - Use strong PIN/password
   - Enable encryption

4. **Be Cautious**
   - Never share recovery phrases
   - Don't install from untrusted sources
   - Verify recipient addresses before sending

---

## 📝 Version History

See [Releases](https://github.com/devmilang99/NeRuWallet/releases) for detailed changelog of features and fixes in each version.

---

**Last Updated:** August 19, 2026  
**Repository:** [devmilang99/NeRuWallet](https://github.com/devmilang99/NeRuWallet)  
**License:** Check repository for license information
