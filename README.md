<div align="center">

<img src="https://img.shields.io/badge/Material--3-Dynamic--UI-6366F1?style=for-the-badge&logo=google&logoColor=white" />
<img src="https://img.shields.io/badge/Animations-Fluid--UX-FF5722?style=for-the-badge&logo=codeforces&logoColor=white" />
<img src="https://img.shields.io/badge/Rust-Cryptography-black?style=for-the-badge&logo=rust&logoColor=white" />
<img src="https://img.shields.io/badge/Security-Hardware--HSM-red?style=for-the-badge&logo=google-cloud&logoColor=white" />
<img src="https://img.shields.io/badge/Flutter-3.11%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white" />

<br /><br />

<!-- Replace with your actual logo -->
# 💎 NeRuWallet

**A Masterpiece of Modern Flutter UI, Anchored in Hardware Security.**
Experience a high-end financial dashboard that combines fluid Material 3 design with industrial-grade, hardware-rooted security.

[Visual Experience](#visual-experience) · [Security Foundation](#security-foundation) · [AI Advisor](#ai-advisor) · [Tech Stack](#tech-stack) · [Architecture](#architecture)

---

</div>

## <a id="overview"></a> 📖 Overview

**NeRuWallet** is a premium financial companion that proves high-end design and high-level security can coexist. It delivers a "Liquid UI" experience—staggered animations, glassmorphism, and responsive layouts—all while maintaining an uncompromising **Security First** posture.

Under the hood, every beautiful interaction is backed by **Rust-powered cryptography** and **Hardware Security Modules (HSM)**, ensuring that your financial data is as secure as it is accessible.

---

## <a id="visual-experience"></a> ✨ The Visual Experience

NeRuWallet is built using the latest **Material 3 (M3)** standards, focusing on depth, motion, and a sophisticated color palette.

### 🎨 Design Language
- **Modern Typography**: Uses the **Outfit** typeface for a clean, geometric, and professional aesthetic across all screens.
- **Glassmorphism & Depth**: Implementation of `GlassDialog` and semi-transparent surfaces to create a sense of hierarchy and modern elegance.
- **Indigo & Emerald Palette**: A carefully curated color system (`0xFF6366F1` and `0xFF10B981`) that balances trust with technological innovation.

### 🌊 Fluid Motion
- **Staggered Animations**: Utilizing `flutter_animate` to create natural, non-intrusive entrance sequences for dashboard elements.
- **Micro-interactions**: Every button press and state change is accompanied by subtle haptic feedback and smooth transitions.
- **Dynamic Charts**: Interactive, animated spending visualizations powered by **FL Chart** that react to user filtering.

---

## <a id="security-foundation"></a> 🛡️ The Hardened Foundation

While the UI is built for beauty, the foundation is built for battle. NeRuWallet moves security from the software layer down to the **Physical Hardware**.

- **HSM Integration**: Utilizes **Android StrongBox** and **iOS Secure Enclave** to generate non-exportable 256-bit EC keys. Private keys never touch the OS memory.
- **Rust Cryptography**: A high-performance **Rust core** (`rust_signer`) handles all data hashing using the **ring** crate, eliminating memory-safety vulnerabilities.
- **Hardware-Gated Biometrics**: Transactions aren't just signed; they are *unlocked* by hardware-level biometric challenges (FaceID/Strong Biometrics).

---

## <a id="ai-advisor"></a> 🤖 Intelligent AI Advisor

NeRuWallet features an integrated **Gemini AI** assistant that provides deep financial forensics through a beautiful chat interface.

- **Financial Storytelling**: Instead of just lists of numbers, the AI generates narrative summaries of your financial health.
- **Visual Insights**: The advisor works in tandem with **FL Chart** to highlight spending trends and savings opportunities.
- **Contextual Safety**: Analysis is performed on data processed through our secure Rust/HSM pipeline.

---

## <a id="tech-stack"></a> 🛠 Tech Stack

| Layer | Technology |
| :--- | :--- |
| **UI & UX** | **Material 3**, **Outfit Font**, **Flutter Animate**, **Lottie** |
| **Visuals** | **FL Chart** (Animated), **Glassmorphism** Widgets |
| **Security Foundation** | **Rust (ring)**, **Android StrongBox**, **iOS Secure Enclave** |
| **State Management** | **Riverpod** (Generator based) |
| **Intelligence** | **Google Gemini AI** (Generative AI SDK) |
| **Backend & Sync** | **Supabase** (Realtime), **Drift** (Local Reactive DB) |

---

## <a id="architecture"></a> 🏗️ System Architecture

NeRuWallet utilizes a **Tiered Feature-First Architecture**:

1.  **Experience Layer**: Fluid, animated UI built with modern M3 components.
2.  **Processing Layer**: High-performance **Rust** hashing via **UniFFI**.
3.  **Root of Trust**: **Hardware HSM** for biometric-gated transaction signing.

```
lib/
├── core/                    # UI Components (Theme, Glass Widgets, Charts)
│   └── theme/               # Material 3 Design System (Indigo/Emerald)
├── features/                # Domain-specific modules (AI, Payments, Auth)
│   ├── ai_advisor/          # Gemini integration & FL Chart presentation
│   └── auth/                # Biometric & HSM signing logic
└── rust_signer/             # The Rust cryptographic core
```

---

## 🚀 Getting Started

### Installation

1.  **Clone the Repo**
    ```bash
    git clone https://github.com/your-username/NeRuWallet.git
    ```
2.  **Setup Environment**
    Configure your `.env` with Supabase and Gemini keys.
3.  **Run with Style**
    ```bash
    flutter run
    ```

---

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">

Where high-end design meets absolute security.

</div>
