<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge" />
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
<img src="https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge" />

<br /><br />

<!-- Replace with your actual logo -->
# 💳 Neru Wallet

### by [NeRuAI](https://neruai.com)

**A next-generation digital wallet built for speed, security, and simplicity.**  
Send, receive, and manage your money — anywhere, anytime.

[Features](#-features) · [Getting Started](#-getting-started) · [Architecture](#-architecture) · [Screenshots](#-screenshots) · [Contributing](#-contributing)

---

</div>

## 📖 Overview

**Neru Wallet** is a production-grade Flutter fintech application developed by **NeRuAI**. It provides users with a seamless digital payment experience — from peer-to-peer transfers and bill payments to transaction history and multi-currency support.

Built with scalability and security at its core, Neru Wallet follows industry-standard fintech practices including end-to-end encryption, biometric authentication, and real-time transaction processing.

---

## ✨ Features

### 💰 Wallet & Transactions
- **Send & Receive Money** — Instant peer-to-peer transfers using phone number, QR code, or wallet ID
- **Transaction History** — Detailed, filterable history with exportable statements
- **Multi-Currency Support** — Hold and transact in multiple currencies with live exchange rates
- **Scheduled Payments** — Set up one-time or recurring payment schedules

### 🔒 Security
- **Biometric Authentication** — Fingerprint and Face ID login
- **PIN Protection** — Secure 6-digit transaction PIN with brute-force lockout
- **End-to-End Encryption** — All sensitive data encrypted in transit and at rest
- **Device Binding** — Account tied to verified device for fraud prevention

### 🏦 Account Management
- **KYC Verification** — In-app identity verification flow
- **Virtual & Physical Cards** — Issue and manage debit/virtual cards
- **Spending Analytics** — Visual breakdown of spending by category and period
- **Notifications** — Real-time push alerts for every transaction

### 🎨 User Experience
- **Clean, Minimal UI** — Intuitive design optimized for one-handed use
- **Dark & Light Themes** — System-aware theming with manual override
- **Offline Mode** — View balance and history without an internet connection
- **Localization** — Multi-language support (English, Nepali, and more)

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.x |
| **State Management** | Riverpod / BLoC |
| **Local Storage** | Hive / SharedPreferences |
| **Remote Data** | Retrofit + Dio (REST API) |
| **Authentication** | Firebase Auth / JWT |
| **Encryption** | `flutter_secure_storage` |
| **Biometrics** | `local_auth` |
| **Payments** | NeRuAI Payment Gateway SDK |
| **Analytics** | Firebase Analytics |
| **CI/CD** | GitHub Actions / Fastlane |
| **Testing** | Flutter Test / Mockito |

---

## 📐 Architecture

Neru Wallet follows a **Clean Architecture** pattern with a layered separation of concerns:

```
lib/
├── core/
│   ├── constants/          # App-wide constants, themes, strings
│   ├── errors/             # Failure & exception classes
│   ├── network/            # Dio client, interceptors
│   └── utils/              # Formatters, validators, extensions
│
├── features/
│   ├── auth/               # Login, registration, biometrics
│   ├── wallet/             # Balance, top-up, withdraw
│   ├── transactions/       # Send, receive, history
│   ├── cards/              # Virtual & physical card management
│   ├── analytics/          # Spending insights & charts
│   └── settings/           # Profile, security, preferences
│
├── shared/
│   ├── widgets/            # Reusable UI components
│   └── providers/          # Shared Riverpod providers
│
└── main.dart
```

Each feature module is structured as:

```
feature/
├── data/
│   ├── datasources/        # Remote & local data sources
│   ├── models/             # JSON-serializable data models
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Abstract repository contracts
│   └── usecases/           # Single-responsibility use cases
└── presentation/
    ├── pages/              # Full screens
    ├── widgets/            # Feature-scoped widgets
    └── providers/          # State management (Riverpod/BLoC)
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- [Dart SDK](https://dart.dev/get-dart) `>=3.0.0`
- Android Studio / VS Code with Flutter extension
- Android SDK (API 21+) or Xcode 14+ for iOS

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/neruai/neru-wallet.git
cd neru-wallet
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Configure environment variables**

Copy the example environment file and fill in your keys:

```bash
cp .env.example .env
```

```env
# .env
NERUAI_API_BASE_URL=https://api.neruai.com/v1
NERUAI_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_firebase_project_id
ENCRYPTION_KEY=your_encryption_key
```

**4. Run code generation** (for Riverpod, Freezed, Retrofit)

```bash
dart run build_runner build --delete-conflicting-outputs
```

**5. Run the app**

```bash
# Debug
flutter run

# Release
flutter run --release
```

---

## 🧪 Running Tests

```bash
# Unit & widget tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🔐 Security & Compliance

Neru Wallet is built with the following security practices:

- All network traffic uses **TLS 1.3**
- Sensitive credentials stored in **platform secure enclave** via `flutter_secure_storage`
- Transaction signing using **HMAC-SHA256**
- No plaintext PII stored locally
- Compliant with **PCI DSS** guidelines for payment data handling
- Regular dependency audits via `dart pub audit`

> ⚠️ **Responsible Disclosure:** Found a security vulnerability? Please email **security@neruai.com** rather than opening a public issue.

---

## 📱 Screenshots

> _Coming soon — screenshots will be added upon first stable release._

| Onboarding | Dashboard | Send Money | Analytics |
|:-----------:|:---------:|:----------:|:---------:|
| _(soon)_ | _(soon)_ | _(soon)_ | _(soon)_ |

---

## 🗺 Roadmap

- [x] Core wallet & transaction flows
- [x] Biometric authentication
- [x] QR code payments
- [ ] Crypto wallet integration
- [ ] In-app card issuance (virtual)
- [ ] Merchant payment portal
- [ ] AI-powered spending insights (NeRuAI engine)
- [ ] Offline-first sync with conflict resolution
- [ ] Apple Pay / Google Pay integration

---

## 🤝 Contributing

We welcome contributions from the community! Please read our contributing guidelines before opening a pull request.

**Development workflow:**

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to your branch: `git push origin feat/your-feature-name`
5. Open a Pull Request against `develop`

**Commit message convention** (following [Conventional Commits](https://www.conventionalcommits.org/)):

```
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Formatting, no logic change
refactor: Code restructuring
test:     Adding or updating tests
chore:    Build process, dependencies
```

Please ensure your code passes all tests and follows the project's lint rules (`flutter analyze`) before submitting.

---

## 📄 License

```
MIT License

Copyright (c) 2025 NeRuAI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📬 Contact & Support

| Channel | Link |
|---|---|
| 🌐 Website | [neruai.com](https://neruai.com) |
| 📧 General | [hello@neruai.com](mailto:hello@neruai.com) |
| 🔒 Security | [security@neruai.com](mailto:security@neruai.com) |
| 🐛 Issues | [GitHub Issues](https://github.com/neruai/neru-wallet/issues) |
| 💬 Community | [Discord / Slack](#) |

---

<div align="center">

Built with ❤️ by the **NeRuAI** team  
© 2025 NeRuAI. All rights reserved.

</div>
