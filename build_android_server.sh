#!/bin/bash

set -e  # Thoát ngay khi gặp lỗi

# 📌 Thiết lập đường dẫn (Cập nhật phiên bản NDK nếu cần)
export NDK_HOME=$HOME/Library/Android/sdk/ndk/27.0.12077973
export LIB_NAME=mobile_server
export ANDROID_LIB_DIR=$LIB_NAME/android
export HEADER_OUT=$ANDROID_LIB_DIR/cpp

# 🔧 Định nghĩa các kiến trúc Android cần build
ARCHS=("aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android")

# 🌍 Thiết lập môi trường cross-compilation
export PKG_CONFIG_ALLOW_CROSS=1
export PKG_CONFIG_SYSROOT_DIR=$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/sysroot

echo "🚀 Bắt đầu build Rust cho Android..."

# 1️⃣ Đảm bảo các target Rust đã được cài đặt
for ARCH in "${ARCHS[@]}"; do
    rustup target add $ARCH
done

# 2️⃣ Build thư viện Rust dưới dạng shared library cho các target
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 build --release

# 3️⃣ Sao chép file .so vào thư mục jniLibs tương ứng của Android
for ARCH in "${ARCHS[@]}"; do
    if [[ "$ARCH" == "aarch64-linux-android" ]]; then
        ANDROID_ARCH="arm64-v8a"
    elif [[ "$ARCH" == "armv7-linux-androideabi" ]]; then
        ANDROID_ARCH="armeabi-v7a"
    elif [[ "$ARCH" == "x86_64-linux-android" ]]; then
        ANDROID_ARCH="x86_64"
    else
        echo "⚠️ Không hỗ trợ kiến trúc: $ARCH"
        exit 1
    fi

    OUT_DIR=$ANDROID_LIB_DIR/jniLibs/$ANDROID_ARCH
    if [ ! -d "$OUT_DIR" ]; then
        echo "📂 Tạo thư mục: $OUT_DIR"
        mkdir -p $OUT_DIR
    fi

    echo "📂 Sao chép lib$LIB_NAME.so vào $OUT_DIR..."
    cp target/$ARCH/release/lib$LIB_NAME.so $OUT_DIR/
done

# 4️⃣ Tạo file header C (cho JNI integration)
echo "📝 Tạo file header..."
if [ ! -d "$HEADER_OUT" ]; then
    echo "📂 Tạo thư mục: $HEADER_OUT"
    mkdir -p $HEADER_OUT
fi

cd $LIB_NAME
cargo install --force cbindgen
cbindgen --lang c --output ../$HEADER_OUT/$LIB_NAME.h
cd ..

echo "✅ Build hoàn tất! Shared libraries và header đã sẵn sàng cho Android."