#!/bin/bash
set -e

# Configuration
PROJECT_NAME="rust_signer"
UDL_FILE="src/rust_signer.udl"
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
    target/aarch64-apple-ios/release/libuniffi_${PROJECT_NAME}.a \
    target/x86_64-apple-ios/release/libuniffi_${PROJECT_NAME}.a \
    -output target/universal/libuniffi_${PROJECT_NAME}.a

echo "✅ Universal library created at rust_signer/target/universal/libuniffi_${PROJECT_NAME}.a"

echo "✨ Generating Swift bindings..."

# Determine bindgen command
if command -v uniffi-bindgen &> /dev/null; then
    BINDGEN="uniffi-bindgen"
else
    # Fallback to cargo run if bindgen is in the workspace
    BINDGEN="cargo run --features uniffi/cli --bin uniffi-bindgen --"
fi

# Generate bindings
# Note: This might need specific CLI flags depending on the uniffi-bindgen version
$BINDGEN generate $UDL_FILE --language swift --out-dir $IOS_DIR

echo "🚀 Done! Remember to add the generated files (rust_signer.swift, rust_signerFFI.h, rust_signerFFI.modulemap) to your Xcode project."
