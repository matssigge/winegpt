use axum::{routing::get, Json, Router};
use std::net::SocketAddr;
use wine_backend::{backend_bind_address, health_response, HealthResponse};

#[tokio::main]
async fn main() {
    let app = Router::new().route("/api/health", get(health));
    let address = load_bind_address();

    println!("backend listening on http://{address}");

    let listener = tokio::net::TcpListener::bind(address)
        .await
        .expect("bind backend listener");

    axum::serve(listener, app)
        .await
        .expect("serve backend");
}

async fn health() -> Json<HealthResponse> {
    Json(health_response())
}

fn load_bind_address() -> SocketAddr {
    let bind_address = std::env::var("BACKEND_BIND_ADDR").ok();

    backend_bind_address(bind_address.as_deref()).expect("parse BACKEND_BIND_ADDR")
}
