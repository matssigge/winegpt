use crate::{database_url, db};
use sqlx::PgPool;
use tokio::sync::Mutex;

static TEST_MUTEX: Mutex<()> = Mutex::const_new(());

pub async fn test_database() -> PgPool {
    let _guard = TEST_MUTEX.lock().await;
    let configured_database_url = std::env::var("DATABASE_URL").ok();
    let database_url =
        database_url(configured_database_url.as_deref()).expect("DATABASE_URL should exist");
    let database = db::connect(database_url)
        .await
        .expect("test database should connect");

    sqlx::query("DELETE FROM collection_memberships")
        .execute(&database)
        .await
        .expect("collection memberships should be cleared");
    sqlx::query("DELETE FROM collections")
        .execute(&database)
        .await
        .expect("collections should be cleared");
    sqlx::query("DELETE FROM sessions")
        .execute(&database)
        .await
        .expect("sessions should be cleared");
    sqlx::query("DELETE FROM users")
        .execute(&database)
        .await
        .expect("users should be cleared");

    drop(_guard);
    database
}
