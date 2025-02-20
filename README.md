Getting Started

Build and Run Demo

To build and run the demo application, navigate to the demo directory and execute the following commands:
```
cd demo

cargo build

cargo run
```
Create Static Library for iOS

For generating a static library for iOS (server iOS), run the following command before executing the shell script:
```
chmod +x build_ios_server.sh

./build_ios_server.sh
```
It will create mobile_server/ios_server.xcframework folder
Copy ios_server.xcframework folder to your ios project, using bridge file mobile_server.h and call rust server.

Create Static Library for Android

For generating a static library for Android (server Android), run the following command before executing the shell script:
```
chmod +x build_android_server.sh

./build_android_server.sh
```
It will create mobile_server/android folder
- cpp/mobile_server.h
- jniLibs/aarch64-linux-android/libmobile_server.a

Copy and paste these files to your Android project, example architechture

android/app/src/main/
├── cpp/              # C++ JNI Code
│   ├── mobile_server.h   # Rust-generated header file (cbindgen)
│   ├── mobile_server.cpp # JNI Bridge (calls Rust functions)
│   ├── CMakeLists.txt    # Native build config
│
├── jniLibs/          # Rust static library
│   ├── arm64-v8a/libmobile_server.a   # Rust compiled .a file
│
└── java/com/example/rustbridge/   # Java wrapper
    ├── RustBridge.java  # Java bridge for Rust functions


1. Configure JNI (C++)
