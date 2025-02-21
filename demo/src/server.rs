//use actix_web::{App, HttpServer, Responder, HttpResponse, get, post, web};
//use serde::{Deserialize, Serialize};
//use tokio::task;
//
//// Define a struct for the JSON request/response
//#[derive(Serialize, Deserialize)]
//struct Message {
//    content: String,
//}
//
//// GET Handler - Returns a welcome message
//#[get("/health_check")]
//async fn health_check() -> impl Responder {
//    HttpResponse::Ok().json(Message {
//        content: "Sunshine & roses!".to_string(),
//    })
//}
//
//#[post("/health_check")]
//async fn post_message(msg: web::Json<Message>) -> impl Responder {
//    let message = msg.into_inner();
//    let response = format!("Received: {}", message.content);
//    HttpResponse::Ok().json(Message { content: response })
//}
//
///// Starts the Actix Web server in a new async task
//#[no_mangle]
//pub async fn start_server() {
//    task::spawn(async {
//        let addr = "127.0.0.1:8080";
//        println!("🚀 Server running at http://{}", addr);
//
//        HttpServer::new(|| {
//            App::new()
//                .service(health_check)
//                .service(post_message)
//        })
//            .bind(addr)
//            .expect("Failed to bind server")
//            .run()
//            .await
//            .expect("Server failed to start");
//    });
//
//    // Keep the Actix runtime alive
//    tokio::signal::ctrl_c().await.expect("Failed to listen for shutdown signal");
//}

use actix_web::{App, HttpServer, Responder, HttpResponse, get, post, web};
use serde::{Deserialize, Serialize};
use tokio::runtime::Runtime;
use tokio::time::{sleep, Duration};
use jni::JNIEnv;
use jni::objects::{JClass, JString};
use jni::sys::jstring;
use std::sync::Once;

static INIT: Once = Once::new();
static mut RUNTIME: Option<Runtime> = None;

#[derive(Serialize, Deserialize)]
struct Message {
    content: String,
}

#[get("/health_check")]
async fn health_check() -> impl Responder {
    HttpResponse::Ok().json(Message {
        content: "Server is running!".to_string(),
    })
}

#[post("/health_check")]
async fn post_message(msg: web::Json<Message>) -> impl Responder {
    let response = format!("Received: {}", msg.content);
    HttpResponse::Ok().json(Message { content: response })
}

/// **Khởi động server**
pub async fn start_server() {
    let addr = "0.0.0.0:8080";
    println!("🚀 Rust: Server is running at http://{}", addr);

    HttpServer::new(|| App::new().service(health_check).service(post_message))
        .bind(addr)
        .expect("❌ Failed to bind server")
        .run()
        .await
        .expect("❌ Server crashed");
}

/// **Hàm gọi từ Android để chạy server**
#[no_mangle]
pub extern "C" fn Java_com_rustserver_MainActivity_start_1server(
    env: JNIEnv,
    _: JClass,
) -> jstring {
    unsafe {
        INIT.call_once(|| {
            let runtime = Runtime::new().expect("❌ Failed to create Tokio runtime");
            RUNTIME = Some(runtime);
        });

        if let Some(runtime) = &RUNTIME {
            runtime.spawn(async {
                start_server().await;
            });
        }
    }

    env.new_string("Server started in Rust").unwrap().into_raw()
}