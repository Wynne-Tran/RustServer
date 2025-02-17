mod server;

#[actix_web::main]
pub async fn main() {
   server::start_server().await;
}
