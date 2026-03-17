use sqlx::PgPool;

#[derive(Debug)]
pub enum DatabaseInitError {
    Connect(sqlx::Error),
    Migrate(sqlx::migrate::MigrateError),
}

pub async fn connect(database_url: &str) -> Result<PgPool, DatabaseInitError> {
    let database = PgPool::connect(database_url)
        .await
        .map_err(DatabaseInitError::Connect)?;

    migrate(&database)
        .await
        .map_err(DatabaseInitError::Migrate)?;

    Ok(database)
}

pub async fn migrate(database: &PgPool) -> Result<(), sqlx::migrate::MigrateError> {
    sqlx::migrate!("./migrations").run(database).await
}

pub async fn ping(database: &PgPool) -> Result<(), sqlx::Error> {
    sqlx::query_scalar::<_, i32>("SELECT 1")
        .fetch_one(database)
        .await
        .map(|_| ())
}
