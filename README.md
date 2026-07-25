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
Built with Flutter, Rust, and Hardware HSMs, NeRuWallet is an engineering-first platform that harmonizes fluid Material 3 design with an uncompromising "Defense in Depth" security architecture.

[Security Pipeline](#security-pipeline) · [Neru AI](#neru-ai) · [UX Philosophy](#ux-philosophy) · [Architecture](#architecture) · [Getting Started](#getting-started)

---

</div>

## <a id="overview"></a> 📖 Project Philosophy

**NeRuWallet** is designed to demonstrate that elite security engineering and premium user experience are not mutually exclusive. Most mobile wallets prioritize ease of use at the cost of software-based vulnerabilities; NeRuWallet anchors every transaction in **Physical Hardware (HSM)** and high-performance **Rust code**, while delivering a modern, "Liquid UI" experience.

---

## <a id="security-pipeline"></a> 🔒 The Secure Signing Pipeline (HSM + Rust)

NeRuWallet implements a unique multi-layered signing pipeline. Private keys are never generated in software and never touch the application's memory.

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
- **Android StrongBox**: Utilizes a dedicated security-certified chip (where available) to generate non-exportable 256-bit EC keys.
- **iOS Secure Enclave**: Leverages the hardware-isolated coprocessor for key generation and cryptographic operations.
- **Biometric Crypto-Gating**: Signatures are physically locked. The hardware only authorizes a signature if a biometric challenge is successfully completed in the same session.

### 🦀 Rust Hashing Layer
To ensure the integrity of the data being signed, a custom **Rust module** handles normalization. By using the `ring` crate, we eliminate entire classes of memory-safety vulnerabilities like buffer overflows that are common in software-only implementations.

---

## <a id="neru-ai"></a> 🤖 Neru AI: The Intelligent Advisor

NeRuWallet integrates **Gemini 3.5 Flash** to provide deep financial forensics. This isn't just a chatbot; it's an autonomous financial agent.

- **Prompt Engineering & JSON Constraints**: All AI interactions are governed by strict system prompts that enforce JSON-only responses, ensuring deterministic integration with the app's UI.
- **Autonomous Preference Management**: The AI can suggest and *automatically update* app preferences (e.g., setting a monthly budget) through structured function calling.
- **Gamified Insights**: To ensure data quality, AI analysis is unlocked only after a user reaches a transaction volume of **Rs. 10,000**, encouraging active financial management.
- **Data Privacy Barrier**: Only aggregated statistics and masked metadata are sent to the AI, maintaining a strict privacy boundary between your financial details and the LLM.

---

## <a id="ux-philosophy"></a> ✨ The "Liquid UI" Strategy

The UI is built on a **Custom Design System** that extends Material 3 with a focus on motion and transparency.

- **Design System**: Built around the **Outfit** typeface and a high-contrast palette of **Indigo (Primary)** and **Emerald (Success)**.
- **Glassmorphism**: Extensive use of `GlassDialog` and backdrop filters to create a layered, modern aesthetic that feels premium and light.
- **Motion Design**: 
    - **Staggered Entrances**: Dashboard elements enter using `flutter_animate` with slight delays to create a fluid, organic feel.
    - **Sliver Architecture**: Native-feeling scrolling experiences using `CustomScrollView` and `SliverAppBar`.
    - **Haptic Feedback**: Micro-interactions are reinforced with subtle vibrations to create a tactile sense of security.

---

## <a id="tech-stack"></a> 🛠 Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Mobile Core** | **Flutter (3.11+)**, **Riverpod (Code Generation)** |
| **Security Hardware** | **Android StrongBox / TEE**, **iOS Secure Enclave** |
| **Systems Layer** | **Rust**, **ring** (Crypto), **UniFFI** (Bridge) |
| **Data Engine** | **Supabase** (Realtime/Auth), **Drift** (Reactive SQLite) |
| **Design & UX** | **Material 3**, **Flutter Animate**, **Lottie**, **FL Chart** |
| **AI Integration** | **Google Gemini 3.5 Flash**, **Prompt Engineering** |

---

## <a id="architecture"></a> 🏗️ Component Architecture

NeRuWallet follows a **Feature-First Architecture**, ensuring that domain logic (AI, Payments, Auth) is isolated and testable.

```mermaid
graph TD
    UI[Flutter UI Layer] --> BL[Business Logic - Riverpod]
    BL --> SS[SecureSigningService]
    BL --> AS[AIService - Gemini]
    SS --> NS[Native Security Provider]
    NS --> RS[Rust Core - ring]
    NS --> HSM[Hardware HSM]
    BL --> DB[Drift Local DB]
    BL --> SB[Supabase Realtime]
```

---

## 🚀 Roadmap

- [ ] **Multi-Signature Wallets**: Shared hardware-backed accounts.
- [ ] **NFC Tap-to-Pay**: Fully integrated contactless transaction pipeline.
- [ ] **Wear OS Companion**: Real-time alerts and biometric verification from your wrist.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built for the future of secure finance.

</div>
