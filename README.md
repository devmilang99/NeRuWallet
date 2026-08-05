<div align="center">

<img src="https://img.shields.io/badge/Security-Hardware--Rooted-red?style=for-the-badge&logo=google-cloud&logoColor=white" />
<img src="https://img.shields.io/badge/Rust-Cryptography-black?style=for-the-badge&logo=rust&logoColor=white" />
<img src="https://img.shields.io/badge/AI-Gemini--3.5--Flash-4285F4?style=for-the-badge&logo=googlegemini&logoColor=white" />
<img src="https://img.shields.io/badge/Material--3-Dynamic--UI-6366F1?style=for-the-badge&logo=google&logoColor=white" />
<img src="https://img.shields.io/badge/Flutter-3.11%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white" />

<br /><br />

<!-- Replace with your actual logo -->

# 🛡️ NeRuWallet

**A High-Security, AI-Powered Financial Transaction Ecosystem.**
Built with Flutter, Rust, and Hardware HSMs, NeRuWallet is an engineering-first platform that
harmonizes fluid Material 3 design with an uncompromising "Defense in Depth" security architecture,
now featuring **Hardware-Backed Multi-Signature Vaults**.

[Security Pipeline](#security-pipeline) · [Neru AI](#neru-ai) · [UX Philosophy](#ux-philosophy) · [Screenshots](#screenshots) · [Architecture](#architecture) · [Getting Started](#getting-started)

---

</div>

## <a id="overview"></a> 📖 Project Philosophy

**NeRuWallet** is designed to demonstrate that elite security engineering and premium user
experience are not mutually exclusive. Most mobile wallets prioritize ease of use at the cost of
software-based vulnerabilities; NeRuWallet anchors every transaction in **Physical Hardware (HSM)**
and high-performance **Rust code**, while delivering a modern, "Liquid UI" experience.

---

## <a id="security-pipeline"></a> 🔒 The Secure Signing Pipeline (HSM + Rust)

NeRuWallet implements a unique multi-layered signing pipeline. Private keys are never generated in
software and never touch the application's memory.

```mermaid
sequenceDiagram
    participant User
    participant Flutter as Flutter UI (Dart)
    participant Rust as Rust Core (ring)
    participant HSM as Hardware HSM (StrongBox/Secure Enclave)
    
    User->>Flutter: Initiates Transaction (e.g. Pay Bill)
    Flutter->>Rust: Send Raw Data (via UniFFI)
    Note over Rust: Normalization & SHA-256 Hashing
    Rust->>Flutter: Return Hash
    Flutter->>User: Request Biometric Auth
    User-->>HSM: FaceID / Strong Biometrics
    HSM->>HSM: Internal Validation & Signing
    HSM-->>Flutter: Return ECDSA Signature (secp256r1)
    Flutter->>Supabase: Submit Signed Payload
```

### 🛡️ Hardware-Rooted Trust

- **Android StrongBox**: Utilizes a dedicated security-certified chip (where available) to generate
  non-exportable 256-bit EC keys.
- **iOS Secure Enclave**: Leverages the hardware-isolated coprocessor for key generation and
  cryptographic operations.
- **Biometric Crypto-Gating**: Signatures are physically locked. The hardware only authorizes a
  signature if a biometric challenge is successfully completed in the same session.

### 🦀 Rust Hashing & Verification Layer

To ensure the integrity of the data being signed, a custom **Rust module** handles normalization and
cryptographic verification. By using the `ring` crate, we eliminate entire classes of memory-safety
vulnerabilities.

- **Signature Verification**: For Multi-Sig transactions, the Rust core validates ECDSA signatures
  from peer devices before the local HSM authorizes a co-signature.
- **High-Performance Hashing**: Transaction data is normalized and hashed using SHA-256 within the
  Rust memory boundary via UniFFI.

### 🛡️ Hardening & Anti-Reverse Engineering

NeRuWallet employs "Defense in Depth" to protect against sophisticated attacks:

- **AOT Obfuscation**: Production builds use Flutter's `--obfuscate` flag to rename Dart symbols,
  making decompilation significantly harder.
- **R8/ProGuard Hardening**: Android binaries are further shrunk and obfuscated using custom
  ProGuard
  rules, targeting internal logic and removing log traces.
- **Environment Integrity**:
    - **Jailbreak/Root Detection**: Blocks execution on compromised devices to prevent runtime
      memory hooking (e.g., via Frida).
    - **Emulator Protection**: Detects virtualized environments to prevent automated dynamic
      analysis.
- **Runtime Protection**:
    - **Active Auth Watchdog**: Monitors the Supabase authentication stream in real-time. If a
      session
      is invalidated (e.g., user deleted via backend or token refresh failure), the app instantly
      triggers a global lock-out and redirects to login, preventing "orphaned" sessions.
    - **Screen Guard**: Prevents screenshots and screen recording on sensitive screens using
      `FLAG_SECURE` (Android) and `isCaptured` detection (iOS).
    - **SSL Pinning**: (Roadmap) Enforces cryptographic trust for connections to Supabase and Gemini
      APIs.

---

## <a id="multi-sig"></a> 🤝 Hardware Multi-Sig Vaults

NeRuWallet enables collaborative finance through **M-of-N Multi-Signature Wallets**. Unlike software
multisigs, every participant's approval is anchored in their own device's hardware.

1. **Identity Exchange**: Users share hardware-backed public keys (non-exportable) to form a vault.
2. **Approval Workflow**: When a transaction is initiated, co-signers receive real-time
   notifications via Supabase.
3. **Biometric Authorization**: Each co-signer must pass a biometric challenge to unlock their
   StrongBox/Secure Enclave and produce a valid signature.
4. **Finalization**: Once the threshold is met, the transaction is cryptographically finalized and
   broadcast.

```mermaid
sequenceDiagram
    participant P1 as Proposer (HSM 1)
    participant SB as Supabase (Real-time)
    participant P2 as Co-Signer (HSM 2)
    participant Rust as Rust Core (ring)
    
    P1->>SB: Propose Multi-Sig Tx + Signature 1
    SB-->>P2: Notification: Transaction Pending
    P2->>P2: View Details & Biometric Auth
    P2->>P2: HSM 2 signs Transaction Hash
    P2->>SB: Submit Signature 2
    SB->>Rust: Aggregated Signatures Verification
    Note over Rust: Validates M-of-N Hardware Keys
    Rust-->>SB: Success / Verification Proof
    SB-->>P1: Transaction Finalized & Broadcast
```

---

## <a id="neru-ai"></a> 🤖 Neru AI: The Intelligent Advisor

NeRuWallet integrates **Gemini 3.5 Flash** to provide deep financial forensics. This isn't just a
chatbot; it's an autonomous financial agent.

- **Prompt Engineering & JSON Constraints**: All AI interactions are governed by strict system
  prompts that enforce JSON-only responses, ensuring deterministic integration with the app's UI.
- **Autonomous Preference Management**: The AI can suggest and *automatically update* app
  preferences (e.g., setting a monthly budget) through structured function calling.
- **Gamified Insights**: To ensure data quality, AI analysis is unlocked only after a user reaches a
  transaction volume of **Rs. 10,000**, encouraging active financial management.
- **Data Privacy Barrier**: Only aggregated statistics and masked metadata are sent to the AI,
  maintaining a strict privacy boundary between your financial details and the LLM.

---

## <a id="ux-philosophy"></a> ✨ The "Liquid UI" Strategy

The UI is built on a **Custom Design System** that extends Material 3 with a focus on motion and
transparency.

- **Design System**: Built around the **Outfit** typeface and a high-contrast palette of **Indigo (
  Primary)** and **Emerald (Success)**.
- **Glassmorphism**: Extensive use of `GlassDialog` and backdrop filters to create a layered, modern
  aesthetic that feels premium and light.
- **Motion Design**:
    - **Staggered Entrances**: Dashboard elements enter using `flutter_animate` with slight delays
      to create a fluid, organic feel.
    - **Sliver Architecture**: Native-feeling scrolling experiences using `CustomScrollView` and
      `SliverAppBar`.
    - **Haptic Feedback**: Micro-interactions are reinforced with subtle vibrations to create a
      tactile sense of security.

---

## <a id="screenshots"></a> 📸 Screenshots

### 🏠 Core Experience

|                 Splash                  |              Login              |                Dashboard                |               Profile               |
|:---------------------------------------:|:-------------------------------:|:---------------------------------------:|:-----------------------------------:|
| ![Splash](screenshots/splashscreen.png) | ![Login](screenshots/login.png) | ![Dashboard](screenshots/dashboard.png) | ![Profile](screenshots/profile.png) |

### 🤖 Neru AI: Intelligence Advisor

|            Initial            |           Analysis            |           Insights            |             Chat              |
|:-----------------------------:|:-----------------------------:|:-----------------------------:|:-----------------------------:|
| ![AI 1](screenshots/ai_1.png) | ![AI 2](screenshots/ai_2.png) | ![AI 3](screenshots/ai_3.png) | ![AI 4](screenshots/ai_4.png) |

### 💸 Secure Transaction Flow

|                 Step 1                 |                 Step 2                 |                 Step 3                 |                 Step 4                 |
|:--------------------------------------:|:--------------------------------------:|:--------------------------------------:|:--------------------------------------:|
| ![Send 1](screenshots/sendMoney_1.png) | ![Send 2](screenshots/sendMoney_2.png) | ![Send 3](screenshots/sendMoney_3.png) | ![Send 4](screenshots/sendMoney_4.png) |

### 📊 Utility & QR

|               History               |            QR Scan            |            QR Code            |
|:-----------------------------------:|:-----------------------------:|:-----------------------------:|
| ![History](screenshots/history.png) | ![QR 1](screenshots/qr_1.png) | ![QR 2](screenshots/qr_2.png) |

---

## <a id="tech-stack"></a> 🛠 Tech Stack

| Layer                  | Technology                                                    |
|:-----------------------|:--------------------------------------------------------------|
| **Mobile Core**        | **Flutter (3.11+)**, **Riverpod (Code Generation)**           |
| **Security Hardware**  | **Android StrongBox / TEE**, **iOS Secure Enclave**           |
| **Systems Layer**      | **Rust**, **ring** (Crypto), **UniFFI** (Bridge)              |
| **Security Hardening** | **R8 Obfuscation**, **Root Detection**, **Screen Protection** |
| **Data Engine**        | **Supabase** (Realtime/Auth), **Drift** (Reactive SQLite)     |
| **Design & UX**        | **Material 3**, **Flutter Animate**, **Lottie**, **FL Chart** |
| **AI Integration**     | **Google Gemini 3.5 Flash**, **Prompt Engineering**           |

---

## <a id="architecture"></a> 🏗️ Component Architecture

NeRuWallet follows a **Feature-First Architecture**, ensuring that domain logic (AI, Payments, Auth)
is isolated and testable.

```mermaid
graph TD
    UI[Flutter UI Layer] --> BL[Business Logic - Riverpod]
    BL --> SS[SecureSigningService]
    BL --> MS[Multi-Sig Coordinator]
    BL --> AS[AIService - Gemini]
    MS --> SB[Supabase Realtime]
    SS --> NS[Native Security Provider]
    NS --> RS[Rust Core - ring]
    NS --> HSM[Hardware HSM]
    BL --> DB[Drift Local DB]
    BL --> SB
    MS --> RS

```

---

## 🚀 Roadmap

- [x] **Multi-Signature Wallets**: Shared hardware-backed accounts.
- [ ] **NFC Tap-to-Pay**: Fully integrated contactless transaction pipeline.
- [ ] **Wear OS Companion**: Real-time alerts and biometric verification from your wrist.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built for the future of secure finance.

</div>
