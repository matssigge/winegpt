use axum::{routing::get, Json, Router};
use std::net::SocketAddr;
use wine_backend::{health_response, HealthResponse};

#[tokio::main]
async fn main() {
    let app = Router::new().route("/api/health", get(health));
    let address = SocketAddr::from(([127, 0, 0, 1], 3000));

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
