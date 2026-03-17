use axum::{
    extract::State,
    http::StatusCode,
    routing::get,
    Json, Router,
};
use sqlx::PgPool;
use std::net::SocketAddr;
use wine_backend::{
    backend_bind_address, database_url, db, health_response, HealthResponse,
};

#[tokio::main]
async fn main() {
    let database = connect_database().await;
    let app = Router::new()
        .route("/api/health", get(health))
        .with_state(AppState { database });
    let address = load_bind_address();

    println!("backend listening on http://{address}");

    let listener = tokio::net::TcpListener::bind(address)
        .await
        .expect("bind backend listener");

    axum::serve(listener, app)
        .await
        .expect("serve backend");
}

#[derive(Clone)]
struct AppState {
    database: PgPool,
}

async fn health(State(state): State<AppState>) -> Result<Json<HealthResponse>, StatusCode> {
    db::ping(&state.database)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    Ok(Json(health_response()))
}

fn load_bind_address() -> SocketAddr {
    let bind_address = std::env::var("BACKEND_BIND_ADDR").ok();

    backend_bind_address(bind_address.as_deref()).expect("parse BACKEND_BIND_ADDR")
}

async fn connect_database() -> PgPool {
    let configured_database_url = std::env::var("DATABASE_URL").ok();
    let database_url =
        database_url(configured_database_url.as_deref()).expect("read DATABASE_URL");
    let database = db::connect(database_url).await.expect("connect to postgres");

    database
}
