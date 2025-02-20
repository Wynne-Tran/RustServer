use std::env;
use std::path::Path;

fn main() {
    let ndk_home = env::var("ANDROID_NDK_HOME").unwrap_or_else(|_| "/Users/wynnetran/Library/Android/sdk/ndk/27.1.12297006".to_string());

    let toolchain_path = format!("{}/toolchains/llvm/prebuilt/darwin-x86_64/bin", ndk_home);

    if Path::new(&toolchain_path).exists() {
        println!("cargo:rustc-link-search={}", toolchain_path);
        println!("cargo:rustc-env=NDK_HOME={}", ndk_home);
    } else {
        panic!("❌ ANDROID_NDK_HOME is not set or incorrect. Please set it to your NDK path.");
    }
}
