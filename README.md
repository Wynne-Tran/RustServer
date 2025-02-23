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

See folder ios-rust.
This is a swift project where adding ios_server.xcframework

Run project and if we got the errors libzstd

Example:
Showing Recent Errors Only
Building for 'iOS-simulator', but linking in dylib (/usr/local/lib/libzstd.1.5.7.dylib) built for 'macOS'

We need to link swift project with libzstd.a for staticlib, in normal ios with link with dynamicLib as libzstd.1.5.7.dylib.

- In Xcode, go to Build Settings
- Search for Library Search Paths (LIBRARY_SEARCH_PATHS)
- Remove any paths pointing to /usr/local/Cellar/zstd/1.5.7/
- Add /usr/local/lib/ if missing and adding libzstd.a here

If your mac dont have /usr/local/lib/libzstd.a
```
git clone https://github.com/facebook/zstd.git
cd zstd
```
-Build libzstd.a:
```
make clean
make lib-release
cp lib/libzstd.a /usr/local/lib/libzstd.a

```
- check your match or device or not :
```
lipo -info /usr/local/lib/libzstd.a
```
for simualtor, you will see: Non-fat file: /usr/local/lib/libzstd.a is architecture: x86_64

- add

Please see "rust-to-ios" swift app.






Create Static Library for Android

For generating a static library for Android (server Android), run the following command before executing the shell script:
```
chmod +x build_android_server.sh

./build_android_server.sh
```
It will create mobile_server/android folder
- jniLibs/aarch64-linux-android/libmobile_server.so (for mac OS)

Copy and paste these files to your Android project
src/main/jniLibs/aarch64-linux-android/libmobile_server.so

In MainActivity.kt
- call the library
```
companion object {
    init {
        System.loadLibrary("mobile_server")
    }
}

external fun start_server()
```

Please see "rust-to-android" kotlin-android app.

