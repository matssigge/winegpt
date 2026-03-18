use axum::{
    extract::{Path, State},
    http::{HeaderMap, StatusCode},
    routing::{get, post},
    Json, Router,
};
use serde::Serialize;
use sqlx::PgPool;
use std::net::SocketAddr;
use tower_http::cors::{AllowOrigin, CorsLayer};
use wine_backend::{
    auth::{self, AuthError, AuthResponse, AuthUser, LoginInput, RegisterInput},
    collections::{
        self, Collection, CollectionError, CreateCollectionInput, InviteCollectionInput,
        InvitedCollectionMember,
    },
    entries::{self, CreateEntryInput, EntryError, WineEntry},
    allowed_frontend_origins, backend_bind_address, database_url, db, health_response,
    HealthResponse,
};

#[tokio::main]
async fn main() {
    let database = connect_database().await;
    let cors = load_cors();
    let app = Router::new()
        .route("/api/auth/login", post(login))
        .route("/api/auth/register", post(register))
        .route("/api/collections", get(list_collections).post(create_collection))
        .route(
            "/api/collections/{id}/entries",
            get(list_entries).post(create_entry),
        )
        .route("/api/collections/{id}/invites", post(invite_collection_member))
        .route("/api/health", get(health))
        .route("/api/me", get(me))
        .layer(cors)
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
    authenticate_user(&state.database, &headers)
        .await
        .map(Json)
        .map_err(map_auth_error)
}

async fn create_collection(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(input): Json<CreateCollectionInput>,
) -> Result<Json<Collection>, (StatusCode, Json<ErrorResponse>)> {
    let user = authenticate_user(&state.database, &headers)
        .await
        .map_err(map_auth_error)?;

    collections::create(&state.database, user.id, &input.name)
        .await
        .map(Json)
        .map_err(map_collection_error)
}

async fn list_collections(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<Vec<Collection>>, (StatusCode, Json<ErrorResponse>)> {
    let user = authenticate_user(&state.database, &headers)
        .await
        .map_err(map_auth_error)?;

    collections::list_for_user(&state.database, user.id)
        .await
        .map(Json)
        .map_err(map_collection_error)
}

async fn invite_collection_member(
    State(state): State<AppState>,
    Path(collection_id): Path<i64>,
    headers: HeaderMap,
    Json(input): Json<InviteCollectionInput>,
) -> Result<Json<InvitedCollectionMember>, (StatusCode, Json<ErrorResponse>)> {
    let user = authenticate_user(&state.database, &headers)
        .await
        .map_err(map_auth_error)?;

    collections::invite_by_email(&state.database, user.id, collection_id, &input.email)
        .await
        .map(Json)
        .map_err(map_collection_error)
}

async fn create_entry(
    State(state): State<AppState>,
    Path(collection_id): Path<i64>,
    headers: HeaderMap,
    Json(input): Json<CreateEntryInput>,
) -> Result<Json<WineEntry>, (StatusCode, Json<ErrorResponse>)> {
    let user = authenticate_user(&state.database, &headers)
        .await
        .map_err(map_auth_error)?;

    entries::create(&state.database, user.id, collection_id, input)
        .await
        .map(Json)
        .map_err(map_entry_error)
}

async fn list_entries(
    State(state): State<AppState>,
    Path(collection_id): Path<i64>,
    headers: HeaderMap,
) -> Result<Json<Vec<WineEntry>>, (StatusCode, Json<ErrorResponse>)> {
    let user = authenticate_user(&state.database, &headers)
        .await
        .map_err(map_auth_error)?;

    entries::list_for_collection(&state.database, user.id, collection_id)
        .await
        .map(Json)
        .map_err(map_entry_error)
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

fn load_cors() -> CorsLayer {
    let configured_frontend_origins = std::env::var("FRONTEND_ORIGINS").ok();
    let allowed_origins = allowed_frontend_origins(configured_frontend_origins.as_deref())
        .into_iter()
        .map(|origin| origin.parse().expect("parse FRONTEND_ORIGINS entry"))
        .collect::<Vec<_>>();

    CorsLayer::new()
        .allow_methods([axum::http::Method::GET, axum::http::Method::POST])
        .allow_headers([axum::http::header::AUTHORIZATION, axum::http::header::CONTENT_TYPE])
        .allow_origin(AllowOrigin::list(allowed_origins))
}

fn bearer_token(headers: &HeaderMap) -> Option<&str> {
    let authorization = headers.get("authorization")?.to_str().ok()?;

    authorization.strip_prefix("Bearer ")
}

async fn authenticate_user(database: &PgPool, headers: &HeaderMap) -> Result<AuthUser, AuthError> {
    let token = bearer_token(headers).ok_or(AuthError::MissingSessionToken)?;

    auth::authenticate(database, token).await
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

fn map_collection_error(error: CollectionError) -> (StatusCode, Json<ErrorResponse>) {
    let (status, code) = match error {
        CollectionError::InvalidName => (StatusCode::BAD_REQUEST, "invalid_collection_name"),
        CollectionError::InvalidEmail => (StatusCode::BAD_REQUEST, "invalid_email"),
        CollectionError::AlreadyMember => (StatusCode::CONFLICT, "already_member"),
        CollectionError::Forbidden => (StatusCode::FORBIDDEN, "forbidden"),
        CollectionError::UserNotFound => (StatusCode::NOT_FOUND, "user_not_found"),
        CollectionError::Database => (StatusCode::INTERNAL_SERVER_ERROR, "internal_error"),
    };

    (status, Json(ErrorResponse { error: code }))
}

fn map_entry_error(error: EntryError) -> (StatusCode, Json<ErrorResponse>) {
    let (status, code) = match error {
        EntryError::InvalidConsumedAt => (StatusCode::BAD_REQUEST, "invalid_consumed_at"),
        EntryError::InvalidRating => (StatusCode::BAD_REQUEST, "invalid_rating"),
        EntryError::Forbidden => (StatusCode::FORBIDDEN, "forbidden"),
        EntryError::Wine(wine_backend::wines::WineError::InvalidName) => {
            (StatusCode::BAD_REQUEST, "invalid_wine_name")
        }
        EntryError::Wine(wine_backend::wines::WineError::InvalidVintage) => {
            (StatusCode::BAD_REQUEST, "invalid_wine_vintage")
        }
        EntryError::Database | EntryError::Wine(wine_backend::wines::WineError::Database) => {
            (StatusCode::INTERNAL_SERVER_ERROR, "internal_error")
        }
    };

    (status, Json(ErrorResponse { error: code }))
}
