# 📱 NeRuWallet iOS Download & Testing Guide

> [!IMPORTANT]
> This document provides instructions for testing NeRuWallet on iOS devices using cloud simulation
> services like **BrowserStack**.
> Because this is an unsigned build, it cannot be installed directly on a real iPhone without
> developer signing.
> For Android users, please refer to the [APK Download Guide](APK_DOWNLOAD_GUIDE.md).

## 🎯 Quick Start

*

*
⬇️ [Download Latest iOS IPA](https://github.com/devmilang99/NeRuWallet/releases/latest/download/NeRuWallet-iOS.ipa)
**

This document provides complete instructions for downloading and testing the latest NeRuWallet
iOS build using BrowserStack.

---

## 📦 What You're Downloading

You are downloading **NeRuWallet** - a secure and scalable digital payment solution built with:

- **Frontend**: Flutter/Dart (96.5%)
- **Security Layer**: Rust-based cryptographic signing (1.7%)
- **AI Intelligence**: Google Gemini Integration
- **Backend**: Supabase (PostgreSQL, Realtime, Auth)

This iOS build is automatically created as an **Unsigned IPA** via GitHub Actions CI/CD pipeline,
specifically optimized for cloud testing environments.

---

## ✅ System Requirements (BrowserStack)

Before testing, ensure you have:

| Requirement              | Specification                                  |
|--------------------------|------------------------------------------------|
| **BrowserStack Account** | Required (Free trial or paid)                  |
| **Storage Space**        | ~100MB for the IPA file                        |
| **Network**              | Stable internet for cloud simulation           |
| **Device Selection**     | iPhone 13 or newer recommended for performance |

---

## 🚀 Testing Methods

### Method 1: BrowserStack Simulation (Recommended / No Mac Required)

Since NeRuWallet generates an unsigned `.ipa` artifact, you can test it using **BrowserStack App
Live** even if you don't own a Mac or an iPhone.

#### Step 1: Download the IPA Asset

1. Go to the [NeRuWallet Latest Release](https://github.com/devmilang99/NeRuWallet/releases/latest)
   page.
2. Download the **NeRuWallet-iOS.ipa** asset.

#### Step 2: Upload to BrowserStack

1. Log in to your [BrowserStack App Live](https://www.browserstack.com/app-live) account.
2. Click on **"Upload"** in the "App" section.
3. Select the `NeRuWallet-iOS.ipa` file you just downloaded.
4. BrowserStack will automatically resign the app for testing on their real cloud devices.

#### Step 3: Select a Device & Launch

1. Choose an iPhone (e.g., iPhone 15 Pro) from the list.
2. BrowserStack will boot the device and install NeRuWallet.
3. Grant permissions (Location, Camera, Notifications) when prompted to test all features.

---

### Method 2: Direct Xcode Installation (For Developers with Mac)

If you have a Mac and a physical iPhone, you can build and run the app directly from source.

```bash
# Step 1: Clone the repository
git clone https://github.com/devmilang99/NeRuWallet.git
cd NeRuWallet

# Step 2: Install Flutter dependencies
flutter pub get

# Step 3: Run code generation & Rust bindings
# Ensure you have Rust and flutter_rust_bridge_codegen installed
flutter_rust_bridge_codegen generate --rust-input crate::api --rust-root rust_signer --dart-output lib/src/rust/ --c-output ios/Runner/frb.h
dart run build_runner build --delete-conflicting-outputs

# Step 4: Open iOS project in Xcode
open ios/Runner.xcworkspace

# Step 5: In Xcode
# - Go to "Signing & Capabilities" and select your Development Team
# - Connect your iPhone via USB
# - Select your device and press "Run" (Cmd+R)
```

---

## 🔒 Security & Permissions

NeRuWallet is built with security as a priority. Here's what the app accesses and why:

| Permission             | Purpose                                                    |
|------------------------|------------------------------------------------------------|
| **INTERNET**           | Connect to Supabase, Gemini AI, and process payments       |
| **CAMERA**             | QR code scanning for quick payment recipients              |
| **READ_CONTACTS**      | Suggest saved contacts as payment recipients               |
| **POST_NOTIFICATIONS** | Real-time updates on your transactions and security alerts |

---

## 🐛 Troubleshooting

### Testing Issues

| Problem                        | Solution                                                         |
|--------------------------------|------------------------------------------------------------------|
| **"IPA failed to upload"**     | Ensure the file is named `NeRuWallet-iOS.ipa` and not corrupted. |
| **"Device session timed out"** | Refresh your BrowserStack tab and restart the session.           |
| **"Location not detected"**    | Enable "GPS" or "Location Simulation" in BrowserStack menu.      |
| **"App crashes on launch"**    | Check if the BrowserStack device OS is iOS 12.0 or higher.       |

### Runtime Issues

| Problem                         | Solution                                                                     |
|---------------------------------|------------------------------------------------------------------------------|
| **"Permission denied" errors**  | Go to iOS Settings within the simulation -> NeRuWallet -> Grant permissions. |
| **Network/sync issues**         | Ensure the simulated device has internet enabled in BrowserStack settings.   |
| **AI Assistant not responding** | Verify that the `.env` keys were correctly set during the build process.     |

---

## 🔄 Updates

When new builds are released:

1. Download the new `NeRuWallet-iOS.ipa` from the releases page.
2. Re-upload it to BrowserStack.
3. Start a new session.

---

## 📊 Build Information

```
Build Type: Release (Unsigned)
Architecture: arm64
Min iOS: 12.0
Target iOS: 17.0+
Language Composition:
  - Dart (Flutter): 96.5%
  - Rust (Cryptography): 1.7%
  - Swift (iOS): 1.5%
```

---

## 📞 Support & Feedback

### Report Bugs on GitHub

- Found a bug? [Open an issue on GitHub](https://github.com/devmilang99/NeRuWallet/issues)
- Include: Simulated device model, iOS version, and steps to reproduce.

### Request Features

- Have a feature
  idea? [Create a feature request](https://github.com/devmilang99/NeRuWallet/discussions)

---

## 🔐 Security Best Practices

1. **Secure Your API Keys** — Never commit your actual `.env` file to the repository.
2. **Use Strong Authentication** — Enable biometric simulation in BrowserStack if available.
3. **Be Cautious** — Only test IPAs downloaded from this official repository.

---

**Last Updated:** August 19, 2026  
**Repository:** [devmilang99/NeRuWallet](https://github.com/devmilang99/NeRuWallet)  
**License:** MIT License

---

<div align="center">

Built with ❤️ by **Milan Ghimire**

</div>
