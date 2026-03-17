use axum::{
    extract::State,
    http::{HeaderMap, StatusCode},
    routing::{get, post},
    Json, Router,
};
use serde::Serialize;
use sqlx::PgPool;
use std::net::SocketAddr;
use wine_backend::{
    auth::{self, AuthError, AuthResponse, AuthUser, LoginInput, RegisterInput},
    backend_bind_address, database_url, db, health_response, HealthResponse,
};

#[tokio::main]
async fn main() {
    let database = connect_database().await;
    let app = Router::new()
        .route("/api/auth/login", post(login))
        .route("/api/auth/register", post(register))
        .route("/api/health", get(health))
        .route("/api/me", get(me))
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

#[derive(Serialize)]
struct ErrorResponse {
    error: &'static str,
}

async fn health(State(state): State<AppState>) -> Result<Json<HealthResponse>, StatusCode> {
    db::ping(&state.database)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    Ok(Json(health_response()))
}

async fn register(
    State(state): State<AppState>,
    Json(input): Json<RegisterInput>,
) -> Result<Json<AuthResponse>, (StatusCode, Json<ErrorResponse>)> {
    auth::register(&state.database, input)
        .await
        .map(Json)
        .map_err(map_auth_error)
}

async fn login(
    State(state): State<AppState>,
    Json(input): Json<LoginInput>,
) -> Result<Json<AuthResponse>, (StatusCode, Json<ErrorResponse>)> {
    auth::login(&state.database, input)
        .await
        .map(Json)
        .map_err(map_auth_error)
}

async fn me(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<AuthUser>, (StatusCode, Json<ErrorResponse>)> {
    let token = bearer_token(&headers).ok_or((
        StatusCode::UNAUTHORIZED,
        Json(ErrorResponse {
            error: "missing_session_token",
        }),
    ))?;

    auth::authenticate(&state.database, token)
        .await
        .map(Json)
        .map_err(map_auth_error)
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

fn bearer_token(headers: &HeaderMap) -> Option<&str> {
    let authorization = headers.get("authorization")?.to_str().ok()?;

    authorization.strip_prefix("Bearer ")
}

fn map_auth_error(error: AuthError) -> (StatusCode, Json<ErrorResponse>) {
    let (status, code) = match error {
        AuthError::InvalidEmail => (StatusCode::BAD_REQUEST, "invalid_email"),
        AuthError::PasswordTooShort => (StatusCode::BAD_REQUEST, "password_too_short"),
        AuthError::EmailTaken => (StatusCode::CONFLICT, "email_taken"),
        AuthError::InvalidCredentials | AuthError::MissingSessionToken => {
            (StatusCode::UNAUTHORIZED, "invalid_credentials")
        }
        AuthError::Database | AuthError::Password => {
            (StatusCode::INTERNAL_SERVER_ERROR, "internal_error")
        }
    };

    (status, Json(ErrorResponse { error: code }))
}
