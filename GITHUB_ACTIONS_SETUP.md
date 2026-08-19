# 🔧 GitHub Actions & Build Artifacts Guide

> This guide walks you through the CI/CD pipeline of NeRuWallet, which automatically generates
> Android APKs and iOS IPAs for testing.

---

## 📋 CI/CD Overview

The NeRuWallet CI/CD workflow (`flutter_ci.yml`) is designed to automate testing and build
generation. It handles complex Rust-to-Dart bindings using `flutter_rust_bridge` and runs on every
push and pull request to the `main` and `develop` branches.

### 🏗️ Workflow Jobs

1. **Run Tests**: Executes all unit and widget tests on a Linux runner.
2. **Build Android Debug APK**: Compiles a debug APK for Android and uploads it as an artifact.
3. **Build iOS App Bundle & IPA**: Compiles an unsigned iOS application on a macOS runner and
   packages it as an `.ipa` file for cloud testing.
4. **Create GitHub Release**: On pushes to `main`, it downloads the built artifacts and creates a
   new "Latest Build" release with permanent download links.

---

## 🔐 GitHub Repository Secrets

To ensure the CI/CD runs correctly, the following secrets should be configured in **Settings →
Secrets and variables → Actions**:

| Secret Name            | Description                     | Required |
|------------------------|---------------------------------|----------|
| `SUPABASE_URL`         | Your Supabase project URL       | Yes      |
| `SUPABASE_ANON_KEY`    | Your Supabase anonymous API key | Yes      |
| `GEMINI_API_KEY`       | Your Google Gemini API key      | Yes      |
| `GOOGLE_WEB_CLIENT_ID` | Client ID for Google Sign-In    | Yes      |
| `ENCRYPTION_KEY`       | Key for Rust-based encryption   | Yes      |
| `ENCRYPTION_IV`        | IV for Rust-based encryption    | Yes      |

---

## 📦 Accessing Build Artifacts

### 1. GitHub Actions (Per-Build)

- Go to the **Actions** tab.
- Click on a specific workflow run.
- Scroll down to the **Artifacts** section to download specific build files (valid for 90 days).

### 2. GitHub Releases (Permanent)

- Go to the **Releases** section on the repository homepage.
- The `latest` release always contains the most recent successful builds from the `main` branch:
    - `NeRuWallet-Android.apk`
    - `NeRuWallet-iOS.ipa`

---

## 🧪 Testing the iOS IPA (No Mac Required)

Since the generated iOS build is **unsigned**, it cannot be installed directly on a physical iPhone
without an Apple Developer account. However, you can test it easily using **BrowserStack**:

1. Download the `NeRuWallet-iOS.ipa` from the latest release.
2. Upload it to [BrowserStack App Live](https://www.browserstack.com/app-live).
3. BrowserStack will resign the app and allow you to test it on real cloud devices.

---

## 🛠️ Modifying the Workflow

The workflow file is located
at [.github/workflows/flutter_ci.yml](.github/workflows/flutter_ci.yml).

### Changing Retention Days

If you want artifacts to expire sooner or later (up to 90 days), modify the `retention-days`
property in the upload step.

---

## 🔄 Workflow Triggers

| Branch    | Event        | Action                                    |
|-----------|--------------|-------------------------------------------|
| `main`    | Push         | Tests + Build + **Create/Update Release** |
| `develop` | Push         | Tests + Build                             |
| Any       | Pull Request | Tests + Build (No Release)                |

---

**Last Updated:** August 19, 2026  
**Repository:** [devmilang99/NeRuWallet](https://github.com/devmilang99/NeRuWallet)
