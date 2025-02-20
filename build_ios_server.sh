#!/bin/bash

set -e

OUT_DIR="mobile_server/include"
XCFRAMEWORK_DIR="mobile_server/ios_server.xcframework"

mkdir -p $OUT_DIR
if [ ! -f "$OUT_DIR/mobile_server.h" ]; then
  echo "📝 Generating header file..."
  cd mobile_server
  cargo install --force cbindgen  # Ensure cbindgen is installed
  cbindgen --lang c --output include/mobile_server.h
  cd ..
else
  echo "✅ Header file already exists, skipping generation."
fi

# ✅ Build Rust for all iOS targets
echo "📦 Building for iOS arm64 (devices)..."
cargo build --release --target aarch64-apple-ios --manifest-path _server/Cargo.toml

echo "📦 Building for iOS x86_64 simulator..."
cargo build --release --target x86_64-apple-ios --manifest-path mobile_server/Cargo.toml

echo "📦 Building for iOS arm64 simulator..."
cargo build --release --target aarch64-apple-ios-sim --manifest-path mobile_server/Cargo.toml

echo "✅ Rust static libraries built!"

# ✅ Merge simulator architectures (x86_64 + arm64_sim)
echo "🔀 Merging simulator architectures..."
lipo -create -output target/universal-ios-simulator.a \
  target/x86_64-apple-ios/release/libios_server.a \
  target/aarch64-apple-ios-sim/release/libios_server.a

# ✅ Remove old XCFramework
rm -rf $XCFRAMEWORK_DIR

# ✅ Create the XCFramework (⚠️ Only one header path)
echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
  -library target/aarch64-apple-ios/release/libios_server.a -headers mobile_server/include/ \
  -library target/universal-ios-simulator.a -headers mobile_server/include/ \
  -output $XCFRAMEWORK_DIR

echo "🎉 XCFramework created successfully: $XCFRAMEWORK_DIR"

# ✅ Cleanup merged universal library
rm -f target/universal-ios-simulator.a

echo "🧹 Cleanup complete!"
