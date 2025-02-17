use actix_web::{App, HttpServer, Responder, HttpResponse, get, post, web};
use serde::{Deserialize, Serialize};
use tokio::task;

// Define a struct for the JSON request/response
#[derive(Serialize, Deserialize)]
struct Message {
    content: String,
}

// GET Handler - Returns a welcome message
#[get("/health_check")]
async fn health_check() -> impl Responder {
    HttpResponse::Ok().json(Message {
        content: "Sunshine & roses!".to_string(),
    })
}

#[post("/health_check")]
async fn post_message(msg: web::Json<Message>) -> impl Responder {
    let message = msg.into_inner();
    let response = format!("Received: {}", message.content);
    HttpResponse::Ok().json(Message { content: response })
}

/// Starts the Actix Web server in a new async task
#[no_mangle]
pub async fn start_server() {
    task::spawn(async {
        let addr = "127.0.0.1:8080";
        println!("🚀 Server running at http://{}", addr);

        HttpServer::new(|| {
            App::new()
                .service(health_check)
                .service(post_message)
        })
            .bind(addr)
            .expect("Failed to bind server")
            .run()
            .await
            .expect("Server failed to start");
    });

    // Keep the Actix runtime alive
    tokio::signal::ctrl_c().await.expect("Failed to listen for shutdown signal");
}
