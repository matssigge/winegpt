use crate::collections::{self, CollectionError};
use serde::{Deserialize, Serialize};
use sqlx::{PgPool, Postgres, Row, Transaction};

#[derive(Debug, Deserialize, Clone)]
pub struct WineInput {
    pub producer: Option<String>,
    pub name: String,
    pub vintage: Option<i32>,
    pub style: Option<String>,
    pub grape: Option<String>,
    pub region: Option<String>,
    pub country: Option<String>,
}

#[derive(Debug, PartialEq, Eq, Serialize)]
pub struct Wine {
    pub id: i64,
    pub producer: Option<String>,
    pub name: String,
    pub vintage: Option<i32>,
    pub style: Option<String>,
    pub grape: Option<String>,
    pub region: Option<String>,
    pub country: Option<String>,
}

#[derive(Debug, PartialEq, Eq, Serialize)]
pub struct CollectionWineSummary {
    pub wine: Wine,
    pub entry_count: i64,
    pub last_consumed_at: String,
}

#[derive(Debug, PartialEq, Eq)]
pub enum WineError {
    InvalidName,
    InvalidVintage,
    Database,
}

pub async fn create_or_find(database: &PgPool, input: WineInput) -> Result<Wine, WineError> {
    let normalized = NormalizedWine::from_input(input)?;

    if let Some(existing) = find_existing(database, &normalized).await? {
        return Ok(existing);
    }

    let row = sqlx::query(
        "INSERT INTO wines (producer, name, vintage, style, grape, region, country)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING id, producer, name, vintage, style, grape, region, country",
    )
    .bind(&normalized.producer)
    .bind(&normalized.name)
    .bind(normalized.vintage)
    .bind(&normalized.style)
    .bind(&normalized.grape)
    .bind(&normalized.region)
    .bind(&normalized.country)
    .fetch_one(database)
    .await
    .map_err(|_| WineError::Database)?;

    wine_from_row(&row)
}

pub(crate) async fn create_or_find_in_transaction(
    transaction: &mut Transaction<'_, Postgres>,
    input: WineInput,
) -> Result<Wine, WineError> {
    let normalized = NormalizedWine::from_input(input)?;

    if let Some(existing) = find_existing_in_transaction(transaction, &normalized).await? {
        return Ok(existing);
    }

    let row = sqlx::query(
        "INSERT INTO wines (producer, name, vintage, style, grape, region, country)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING id, producer, name, vintage, style, grape, region, country",
    )
    .bind(&normalized.producer)
    .bind(&normalized.name)
    .bind(normalized.vintage)
    .bind(&normalized.style)
    .bind(&normalized.grape)
    .bind(&normalized.region)
    .bind(&normalized.country)
    .fetch_one(&mut **transaction)
    .await
    .map_err(|_| WineError::Database)?;

    wine_from_row(&row)
}

pub async fn list_for_collection(
    database: &PgPool,
    user_id: i64,
    collection_id: i64,
) -> Result<Vec<CollectionWineSummary>, CollectionError> {
    collections::require_membership(database, user_id, collection_id).await?;

    let rows = sqlx::query(
        "SELECT
            wines.id AS wine_id,
            wines.producer AS wine_producer,
            wines.name AS wine_name,
            wines.vintage AS wine_vintage,
            wines.style AS wine_style,
            wines.grape AS wine_grape,
            wines.region AS wine_region,
            wines.country AS wine_country,
            COUNT(wine_entries.id) AS entry_count,
            to_char(
              MAX(wine_entries.consumed_at) AT TIME ZONE 'UTC',
              'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'
            ) AS last_consumed_at
         FROM wine_entries
         INNER JOIN wines ON wines.id = wine_entries.wine_id
         WHERE wine_entries.collection_id = $1
         GROUP BY
            wines.id,
            wines.producer,
            wines.name,
            wines.vintage,
            wines.style,
            wines.grape,
            wines.region,
            wines.country
         ORDER BY
            MAX(wine_entries.consumed_at) DESC,
            wines.name ASC,
            wines.id ASC",
    )
    .bind(collection_id)
    .fetch_all(database)
    .await
    .map_err(|_| CollectionError::Database)?;

    rows.into_iter().map(summary_from_row).collect()
}

#[derive(Debug)]
struct NormalizedWine {
    producer: Option<String>,
    name: String,
    vintage: Option<i32>,
    style: Option<String>,
    grape: Option<String>,
    region: Option<String>,
    country: Option<String>,
}

impl NormalizedWine {
    fn from_input(input: WineInput) -> Result<Self, WineError> {
        let name = normalize_required_text(&input.name).ok_or(WineError::InvalidName)?;
        let vintage = normalize_vintage(input.vintage)?;

        Ok(Self {
            producer: normalize_optional_text(input.producer),
            name,
            vintage,
            style: normalize_optional_text(input.style),
            grape: normalize_optional_text(input.grape),
            region: normalize_optional_text(input.region),
            country: normalize_optional_text(input.country),
        })
    }
}

async fn find_existing(
    database: &PgPool,
    wine: &NormalizedWine,
) -> Result<Option<Wine>, WineError> {
    let row = sqlx::query(
        "SELECT id, producer, name, vintage, style, grape, region, country
         FROM wines
         WHERE producer IS NOT DISTINCT FROM $1
           AND name = $2
           AND vintage IS NOT DISTINCT FROM $3
           AND style IS NOT DISTINCT FROM $4
           AND grape IS NOT DISTINCT FROM $5
           AND region IS NOT DISTINCT FROM $6
           AND country IS NOT DISTINCT FROM $7
         ORDER BY id ASC
         LIMIT 1",
    )
    .bind(&wine.producer)
    .bind(&wine.name)
    .bind(wine.vintage)
    .bind(&wine.style)
    .bind(&wine.grape)
    .bind(&wine.region)
    .bind(&wine.country)
    .fetch_optional(database)
    .await
    .map_err(|_| WineError::Database)?;

    row.map(|row| wine_from_row(&row)).transpose()
}

async fn find_existing_in_transaction(
    transaction: &mut Transaction<'_, Postgres>,
    wine: &NormalizedWine,
) -> Result<Option<Wine>, WineError> {
    let row = sqlx::query(
        "SELECT id, producer, name, vintage, style, grape, region, country
         FROM wines
         WHERE producer IS NOT DISTINCT FROM $1
           AND name = $2
           AND vintage IS NOT DISTINCT FROM $3
           AND style IS NOT DISTINCT FROM $4
           AND grape IS NOT DISTINCT FROM $5
           AND region IS NOT DISTINCT FROM $6
           AND country IS NOT DISTINCT FROM $7
         ORDER BY id ASC
         LIMIT 1",
    )
    .bind(&wine.producer)
    .bind(&wine.name)
    .bind(wine.vintage)
    .bind(&wine.style)
    .bind(&wine.grape)
    .bind(&wine.region)
    .bind(&wine.country)
    .fetch_optional(&mut **transaction)
    .await
    .map_err(|_| WineError::Database)?;

    row.map(|row| wine_from_row(&row)).transpose()
}

fn wine_from_row(row: &sqlx::postgres::PgRow) -> Result<Wine, WineError> {
    Ok(Wine {
        id: row.try_get("id").map_err(|_| WineError::Database)?,
        producer: row.try_get("producer").map_err(|_| WineError::Database)?,
        name: row.try_get("name").map_err(|_| WineError::Database)?,
        vintage: row.try_get("vintage").map_err(|_| WineError::Database)?,
        style: row.try_get("style").map_err(|_| WineError::Database)?,
        grape: row.try_get("grape").map_err(|_| WineError::Database)?,
        region: row.try_get("region").map_err(|_| WineError::Database)?,
        country: row.try_get("country").map_err(|_| WineError::Database)?,
    })
}

fn summary_from_row(row: sqlx::postgres::PgRow) -> Result<CollectionWineSummary, CollectionError> {
    Ok(CollectionWineSummary {
        wine: Wine {
            id: row.try_get("wine_id").map_err(|_| CollectionError::Database)?,
            producer: row
                .try_get("wine_producer")
                .map_err(|_| CollectionError::Database)?,
            name: row
                .try_get("wine_name")
                .map_err(|_| CollectionError::Database)?,
            vintage: row
                .try_get("wine_vintage")
                .map_err(|_| CollectionError::Database)?,
            style: row
                .try_get("wine_style")
                .map_err(|_| CollectionError::Database)?,
            grape: row
                .try_get("wine_grape")
                .map_err(|_| CollectionError::Database)?,
            region: row
                .try_get("wine_region")
                .map_err(|_| CollectionError::Database)?,
            country: row
                .try_get("wine_country")
                .map_err(|_| CollectionError::Database)?,
        },
        entry_count: row
            .try_get("entry_count")
            .map_err(|_| CollectionError::Database)?,
        last_consumed_at: row
            .try_get("last_consumed_at")
            .map_err(|_| CollectionError::Database)?,
    })
}

fn normalize_required_text(value: &str) -> Option<String> {
    let trimmed = value.trim();

    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

fn normalize_optional_text(value: Option<String>) -> Option<String> {
    value.and_then(|value| normalize_required_text(&value))
}

fn normalize_vintage(vintage: Option<i32>) -> Result<Option<i32>, WineError> {
    match vintage {
        Some(value) if !(1900..=2100).contains(&value) => Err(WineError::InvalidVintage),
        Some(value) => Ok(Some(value)),
        None => Ok(None),
    }
}

#[cfg(test)]
mod tests {
    use super::{
        create_or_find, list_for_collection, CollectionWineSummary, WineError, WineInput,
    };
    use crate::{
        auth::{register, RegisterInput},
        collections::{self, CollectionError},
        entries,
        test_support::test_database,
    };
    use uuid::Uuid;

    #[tokio::test]
    async fn creates_new_wine() {
        let database = test_database().await;

        let wine = create_or_find(
            &database,
            WineInput {
                producer: Some("Envinate".to_string()),
                name: "Taganan".to_string(),
                vintage: Some(2022),
                style: Some("Red".to_string()),
                grape: Some("Listan Negro".to_string()),
                region: Some("Tenerife".to_string()),
                country: Some("Spain".to_string()),
            },
        )
        .await
        .expect("wine should be created");

        assert_eq!(wine.name, "Taganan");
        assert_eq!(wine.vintage, Some(2022));
    }

    #[tokio::test]
    async fn reuses_existing_wine_for_exact_match() {
        let database = test_database().await;

        let first = create_or_find(
            &database,
            WineInput {
                producer: Some("Envinate".to_string()),
                name: "Taganan".to_string(),
                vintage: Some(2022),
                style: Some("Red".to_string()),
                grape: Some("Listan Negro".to_string()),
                region: Some("Tenerife".to_string()),
                country: Some("Spain".to_string()),
            },
        )
        .await
        .expect("first wine should be created");

        let second = create_or_find(
            &database,
            WineInput {
                producer: Some(" Envinate ".to_string()),
                name: " Taganan ".to_string(),
                vintage: Some(2022),
                style: Some("Red".to_string()),
                grape: Some("Listan Negro".to_string()),
                region: Some("Tenerife".to_string()),
                country: Some("Spain".to_string()),
            },
        )
        .await
        .expect("matching wine should be reused");

        assert_eq!(second.id, first.id);
    }

    #[tokio::test]
    async fn creates_new_wine_for_different_identity() {
        let database = test_database().await;

        let first = create_or_find(
            &database,
            WineInput {
                producer: Some("Envinate".to_string()),
                name: "Taganan".to_string(),
                vintage: Some(2022),
                style: None,
                grape: None,
                region: None,
                country: None,
            },
        )
        .await
        .expect("first wine should be created");

        let second = create_or_find(
            &database,
            WineInput {
                producer: Some("Envinate".to_string()),
                name: "Taganan".to_string(),
                vintage: Some(2021),
                style: None,
                grape: None,
                region: None,
                country: None,
            },
        )
        .await
        .expect("different vintage should create a new wine");

        assert_ne!(second.id, first.id);
    }

    #[tokio::test]
    async fn rejects_blank_name() {
        let database = test_database().await;
        let result = create_or_find(
            &database,
            WineInput {
                producer: None,
                name: "   ".to_string(),
                vintage: None,
                style: None,
                grape: None,
                region: None,
                country: None,
            },
        )
        .await;

        assert_eq!(result, Err(WineError::InvalidName));
    }

    #[tokio::test]
    async fn rejects_invalid_vintage() {
        let database = test_database().await;
        let result = create_or_find(
            &database,
            WineInput {
                producer: None,
                name: "Taganan".to_string(),
                vintage: Some(1800),
                style: None,
                grape: None,
                region: None,
                country: None,
            },
        )
        .await;

        assert_eq!(result, Err(WineError::InvalidVintage));
    }

    #[tokio::test]
    async fn lists_collection_wines_as_summaries() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = collections::create(&database, user.id, "Home").await.unwrap();

        create_entry(
            &database,
            user.id,
            collection.id,
            "Taganan",
            Some("Listan Negro"),
            Some(2022),
            "2025-01-15T19:30:00Z",
        )
        .await;
        create_entry(
            &database,
            user.id,
            collection.id,
            "Taganan",
            Some("Listan Negro"),
            Some(2022),
            "2025-01-18T19:30:00Z",
        )
        .await;
        create_entry(
            &database,
            user.id,
            collection.id,
            "Punta de Flechas",
            Some("Malbec"),
            Some(2021),
            "2025-01-17T19:30:00Z",
        )
        .await;

        let wines = list_for_collection(&database, user.id, collection.id)
            .await
            .expect("collection wines should list");

        assert_eq!(wines.len(), 2);
        assert_eq!(wines[0].wine.name, "Taganan");
        assert_eq!(wines[0].wine.grape.as_deref(), Some("Listan Negro"));
        assert_eq!(wines[0].entry_count, 2);
        assert_eq!(wines[0].last_consumed_at, "2025-01-18T19:30:00Z");
        assert_eq!(wines[1].wine.name, "Punta de Flechas");
        assert_eq!(wines[1].entry_count, 1);
    }

    #[tokio::test]
    async fn rejects_non_member_collection_wine_listing() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let stranger = register_user(&database).await;
        let collection = collections::create(&database, owner.id, "Home").await.unwrap();

        let result = list_for_collection(&database, stranger.id, collection.id).await;

        assert_eq!(result, Err(CollectionError::Forbidden));
    }

    #[tokio::test]
    async fn orders_collection_wines_by_most_recent_entry() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = collections::create(&database, user.id, "Home").await.unwrap();

        create_entry(
            &database,
            user.id,
            collection.id,
            "Alpha",
            None,
            Some(2022),
            "2025-01-15T19:30:00Z",
        )
        .await;
        create_entry(
            &database,
            user.id,
            collection.id,
            "Bravo",
            None,
            Some(2021),
            "2025-01-18T19:30:00Z",
        )
        .await;

        let wines = list_for_collection(&database, user.id, collection.id)
            .await
            .expect("collection wines should list");

        assert_eq!(wine_names(&wines), vec!["Bravo".to_string(), "Alpha".to_string()]);
    }

    async fn register_user(database: &sqlx::PgPool) -> crate::auth::AuthUser {
        let email = format!("{}@example.com", Uuid::new_v4().simple());
        let response = register(
            database,
            RegisterInput {
                email,
                full_name: None,
                password: "password123".to_string(),
            },
        )
        .await
        .expect("user registration should succeed");

        response.user
    }

    async fn create_entry(
        database: &sqlx::PgPool,
        user_id: i64,
        collection_id: i64,
        name: &str,
        grape: Option<&str>,
        vintage: Option<i32>,
        consumed_at: &str,
    ) {
        entries::create(
            database,
            user_id,
            collection_id,
            entries::CreateEntryInput {
                wine: WineInput {
                    producer: Some("Envinate".to_string()),
                    name: name.to_string(),
                    vintage,
                    style: None,
                    grape: grape.map(str::to_string),
                    region: None,
                    country: None,
                },
                consumed_at: consumed_at.to_string(),
                venue_name: None,
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(4),
            },
        )
        .await
        .expect("entry should be created");
    }

    fn wine_names(wines: &[CollectionWineSummary]) -> Vec<String> {
        wines.iter().map(|summary| summary.wine.name.clone()).collect()
    }
}
