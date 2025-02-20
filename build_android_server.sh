#!/bin/bash

set -e  # Exit immediately on error

# 📌 Set paths (Update NDK version if necessary)
export NDK_HOME=$HOME/Library/Android/sdk/ndk/27.0.12077973
export LIB_NAME=mobile_server
export ANDROID_LIB_DIR=$LIB_NAME/android
export HEADER_OUT=$ANDROID_LIB_DIR/cpp

# 🔧 Define Android architectures
ARCHS=("aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android")

# 🌍 Set environment variables for cross-compilation
export PKG_CONFIG_ALLOW_CROSS=1
export PKG_CONFIG_SYSROOT_DIR=$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/sysroot

echo "🚀 Starting Android Rust build..."

# 1️⃣ Ensure Rust targets are installed
for ARCH in "${ARCHS[@]}"; do
    rustup target add $ARCH || true
done

# 2️⃣ Build Rust shared libraries for all targets
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 build --release

# 3️⃣ Copy the .so files to the correct Android jniLibs folder
for ARCH in "${ARCHS[@]}"; do
    case $ARCH in
        "aarch64-linux-android") ANDROID_ARCH="arm64-v8a" ;;
        "armv7-linux-androideabi") ANDROID_ARCH="armeabi-v7a" ;;
        "x86_64-linux-android") ANDROID_ARCH="x86_64" ;;
        *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    OUT_DIR=$ANDROID_LIB_DIR/jniLibs/$ANDROID_ARCH
    mkdir -p "$OUT_DIR"

    echo "📂 Copying lib$LIB_NAME.so to $OUT_DIR..."
    cp target/$ARCH/release/lib$LIB_NAME.so "$OUT_DIR/" || {
        echo "❌ Failed to copy lib$LIB_NAME.so for $ANDROID_ARCH"
        exit 1
    }
done

# 4️⃣ Generate C header file (for JNI integration)
echo "📝 Generating header file..."
mkdir -p "$HEADER_OUT"

cd $LIB_NAME
cargo install --force cbindgen
cbindgen --lang c --output ../$HEADER_OUT/$LIB_NAME.h
cd ..

echo "✅ Build complete! Shared libraries and headers are ready for Android."
