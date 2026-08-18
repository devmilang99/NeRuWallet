#!/bin/bash
set -e

# Configuration
PROJECT_NAME="rust_signer"
IOS_DIR="../ios/Runner"

# Navigate to rust_signer directory
cd "$(dirname "$0")/../rust_signer"

echo "🔨 Building Rust library for iOS targets..."

# Add targets if missing
rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim

# Build for architectures
cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-ios
cargo build --release --target aarch64-apple-ios-sim

# Create universal library (Simulator + Device)
mkdir -p target/universal
lipo -create \
    target/aarch64-apple-ios/release/lib${PROJECT_NAME}.a \
    target/x86_64-apple-ios/release/lib${PROJECT_NAME}.a \
    -output target/universal/lib${PROJECT_NAME}.a

echo "✅ Universal library created at rust_signer/target/universal/lib${PROJECT_NAME}.a"

echo "✨ Regenerating bindings..."
flutter_rust_bridge_codegen generate

echo "🚀 Done! Ensure lib${PROJECT_NAME}.a is linked in your Xcode project."
