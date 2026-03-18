use crate::{
    collections::{self, CollectionError},
    wines::{self, Wine, WineError, WineInput},
};
use serde::{Deserialize, Serialize};
use sqlx::{PgPool, Row};

#[derive(Debug, Deserialize)]
pub struct CreateEntryInput {
    pub wine: WineInput,
    pub consumed_at: String,
    pub venue_name: Option<String>,
    pub location_text: Option<String>,
    pub pairing_notes: Option<String>,
    pub tasting_notes: Option<String>,
    pub rating: Option<i16>,
}

#[derive(Debug, PartialEq, Eq, Serialize)]
pub struct WineEntry {
    pub id: i64,
    pub collection_id: i64,
    pub wine: Wine,
    pub created_by_user_id: i64,
    pub consumed_at: String,
    pub venue_name: Option<String>,
    pub location_text: Option<String>,
    pub pairing_notes: Option<String>,
    pub tasting_notes: Option<String>,
    pub rating: Option<i16>,
}

#[derive(Debug, PartialEq, Eq)]
pub enum EntryError {
    InvalidConsumedAt,
    InvalidRating,
    Forbidden,
    Database,
    Wine(WineError),
}

pub async fn create(
    database: &PgPool,
    user_id: i64,
    collection_id: i64,
    input: CreateEntryInput,
) -> Result<WineEntry, EntryError> {
    collections::require_membership(database, user_id, collection_id)
        .await
        .map_err(map_collection_error)?;

    let consumed_at = normalize_consumed_at(&input.consumed_at)?;
    let rating = normalize_rating(input.rating)?;
    let venue_name = normalize_optional_text(input.venue_name);
    let location_text = normalize_optional_text(input.location_text);
    let pairing_notes = normalize_optional_text(input.pairing_notes);
    let tasting_notes = normalize_optional_text(input.tasting_notes);

    let mut transaction = database.begin().await.map_err(|_| EntryError::Database)?;
    let wine = wines::create_or_find_in_transaction(&mut transaction, input.wine)
        .await
        .map_err(EntryError::Wine)?;

    let row = sqlx::query(
        "INSERT INTO wine_entries (
            collection_id,
            wine_id,
            created_by_user_id,
            consumed_at,
            venue_name,
            location_text,
            pairing_notes,
            tasting_notes,
            rating
         )
         VALUES ($1, $2, $3, $4::timestamptz, $5, $6, $7, $8, $9)
         RETURNING id, collection_id, created_by_user_id,
                   to_char(consumed_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS consumed_at,
                   venue_name, location_text, pairing_notes, tasting_notes, rating",
    )
    .bind(collection_id)
    .bind(wine.id)
    .bind(user_id)
    .bind(&consumed_at)
    .bind(&venue_name)
    .bind(&location_text)
    .bind(&pairing_notes)
    .bind(&tasting_notes)
    .bind(rating)
    .fetch_one(&mut *transaction)
    .await
    .map_err(|_| EntryError::Database)?;

    transaction.commit().await.map_err(|_| EntryError::Database)?;

    Ok(WineEntry {
        id: row.try_get("id").map_err(|_| EntryError::Database)?,
        collection_id: row
            .try_get("collection_id")
            .map_err(|_| EntryError::Database)?,
        wine,
        created_by_user_id: row
            .try_get("created_by_user_id")
            .map_err(|_| EntryError::Database)?,
        consumed_at: row
            .try_get("consumed_at")
            .map_err(|_| EntryError::Database)?,
        venue_name: row.try_get("venue_name").map_err(|_| EntryError::Database)?,
        location_text: row
            .try_get("location_text")
            .map_err(|_| EntryError::Database)?,
        pairing_notes: row
            .try_get("pairing_notes")
            .map_err(|_| EntryError::Database)?,
        tasting_notes: row
            .try_get("tasting_notes")
            .map_err(|_| EntryError::Database)?,
        rating: row.try_get("rating").map_err(|_| EntryError::Database)?,
    })
}

pub async fn list_for_collection(
    database: &PgPool,
    user_id: i64,
    collection_id: i64,
) -> Result<Vec<WineEntry>, EntryError> {
    collections::require_membership(database, user_id, collection_id)
        .await
        .map_err(map_collection_error)?;

    let rows = sqlx::query(
        "SELECT
            wine_entries.id,
            wine_entries.collection_id,
            wine_entries.created_by_user_id,
            to_char(wine_entries.consumed_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS consumed_at,
            wine_entries.venue_name,
            wine_entries.location_text,
            wine_entries.pairing_notes,
            wine_entries.tasting_notes,
            wine_entries.rating,
            wines.id AS wine_id,
            wines.producer AS wine_producer,
            wines.name AS wine_name,
            wines.vintage AS wine_vintage,
            wines.style AS wine_style,
            wines.grape AS wine_grape,
            wines.region AS wine_region,
            wines.country AS wine_country
         FROM wine_entries
         INNER JOIN wines ON wines.id = wine_entries.wine_id
         WHERE wine_entries.collection_id = $1
         ORDER BY wine_entries.consumed_at DESC, wine_entries.id DESC",
    )
    .bind(collection_id)
    .fetch_all(database)
    .await
    .map_err(|_| EntryError::Database)?;

    rows.into_iter().map(entry_from_row).collect()
}

fn normalize_consumed_at(consumed_at: &str) -> Result<String, EntryError> {
    let trimmed = consumed_at.trim();

    if trimmed.is_empty() {
        Err(EntryError::InvalidConsumedAt)
    } else {
        Ok(trimmed.to_string())
    }
}

fn normalize_optional_text(value: Option<String>) -> Option<String> {
    value.and_then(|value| {
        let trimmed = value.trim().to_string();

        if trimmed.is_empty() {
            None
        } else {
            Some(trimmed)
        }
    })
}

fn normalize_rating(rating: Option<i16>) -> Result<Option<i16>, EntryError> {
    match rating {
        Some(value) if !(1..=5).contains(&value) => Err(EntryError::InvalidRating),
        Some(value) => Ok(Some(value)),
        None => Ok(None),
    }
}

fn map_collection_error(error: CollectionError) -> EntryError {
    match error {
        CollectionError::Forbidden => EntryError::Forbidden,
        CollectionError::Database => EntryError::Database,
        CollectionError::InvalidName
        | CollectionError::InvalidEmail
        | CollectionError::AlreadyMember
        | CollectionError::UserNotFound => EntryError::Database,
    }
}

fn entry_from_row(row: sqlx::postgres::PgRow) -> Result<WineEntry, EntryError> {
    Ok(WineEntry {
        id: row.try_get("id").map_err(|_| EntryError::Database)?,
        collection_id: row
            .try_get("collection_id")
            .map_err(|_| EntryError::Database)?,
        wine: Wine {
            id: row.try_get("wine_id").map_err(|_| EntryError::Database)?,
            producer: row
                .try_get("wine_producer")
                .map_err(|_| EntryError::Database)?,
            name: row.try_get("wine_name").map_err(|_| EntryError::Database)?,
            vintage: row
                .try_get("wine_vintage")
                .map_err(|_| EntryError::Database)?,
            style: row.try_get("wine_style").map_err(|_| EntryError::Database)?,
            grape: row.try_get("wine_grape").map_err(|_| EntryError::Database)?,
            region: row.try_get("wine_region").map_err(|_| EntryError::Database)?,
            country: row
                .try_get("wine_country")
                .map_err(|_| EntryError::Database)?,
        },
        created_by_user_id: row
            .try_get("created_by_user_id")
            .map_err(|_| EntryError::Database)?,
        consumed_at: row
            .try_get("consumed_at")
            .map_err(|_| EntryError::Database)?,
        venue_name: row.try_get("venue_name").map_err(|_| EntryError::Database)?,
        location_text: row
            .try_get("location_text")
            .map_err(|_| EntryError::Database)?,
        pairing_notes: row
            .try_get("pairing_notes")
            .map_err(|_| EntryError::Database)?,
        tasting_notes: row
            .try_get("tasting_notes")
            .map_err(|_| EntryError::Database)?,
        rating: row.try_get("rating").map_err(|_| EntryError::Database)?,
    })
}

#[cfg(test)]
mod tests {
    use super::{create, list_for_collection, CreateEntryInput, EntryError};
    use crate::{
        auth::{register, RegisterInput},
        collections,
        test_support::test_database,
        wines::WineInput,
    };
    use sqlx::Row;
    use uuid::Uuid;

    #[tokio::test]
    async fn creates_entry_and_wine_for_collection_member() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = collections::create(&database, user.id, "Home").await.unwrap();

        let entry = create(
            &database,
            user.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Taganan", Some(2022)),
                consumed_at: "2025-01-15T19:30:00Z".to_string(),
                venue_name: Some("Home".to_string()),
                location_text: Some("Stockholm".to_string()),
                pairing_notes: Some("Roast chicken".to_string()),
                tasting_notes: Some("Salty and bright".to_string()),
                rating: Some(4),
            },
        )
        .await
        .expect("entry should be created");

        assert_eq!(entry.collection_id, collection.id);
        assert_eq!(entry.wine.name, "Taganan");
        assert_eq!(entry.rating, Some(4));

        let stored = sqlx::query("SELECT wine_id FROM wine_entries WHERE id = $1")
            .bind(entry.id)
            .fetch_one(&database)
            .await
            .expect("entry should be stored");
        let wine_id: i64 = stored.try_get("wine_id").expect("wine id should exist");
        assert_eq!(wine_id, entry.wine.id);
    }

    #[tokio::test]
    async fn reuses_existing_wine_for_repeated_entries() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = collections::create(&database, user.id, "Home").await.unwrap();

        let first = create(
            &database,
            user.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Taganan", Some(2022)),
                consumed_at: "2025-01-15T19:30:00Z".to_string(),
                venue_name: None,
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(4),
            },
        )
        .await
        .expect("first entry should be created");

        let second = create(
            &database,
            user.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Taganan", Some(2022)),
                consumed_at: "2025-01-18T19:30:00Z".to_string(),
                venue_name: None,
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(5),
            },
        )
        .await
        .expect("second entry should be created");

        assert_ne!(first.id, second.id);
        assert_eq!(first.wine.id, second.wine.id);
    }

    #[tokio::test]
    async fn rejects_non_member_entry_creation() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let stranger = register_user(&database).await;
        let collection = collections::create(&database, owner.id, "Home").await.unwrap();

        let result = create(
            &database,
            stranger.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Taganan", Some(2022)),
                consumed_at: "2025-01-15T19:30:00Z".to_string(),
                venue_name: None,
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(4),
            },
        )
        .await;

        assert_eq!(result, Err(EntryError::Forbidden));
    }

    #[tokio::test]
    async fn rejects_invalid_rating() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = collections::create(&database, user.id, "Home").await.unwrap();

        let result = create(
            &database,
            user.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Taganan", Some(2022)),
                consumed_at: "2025-01-15T19:30:00Z".to_string(),
                venue_name: None,
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(6),
            },
        )
        .await;

        assert_eq!(result, Err(EntryError::InvalidRating));
    }

    #[tokio::test]
    async fn rejects_blank_consumed_at() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = collections::create(&database, user.id, "Home").await.unwrap();

        let result = create(
            &database,
            user.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Taganan", Some(2022)),
                consumed_at: "   ".to_string(),
                venue_name: None,
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(4),
            },
        )
        .await;

        assert_eq!(result, Err(EntryError::InvalidConsumedAt));
    }

    #[tokio::test]
    async fn lists_entries_for_collection_in_descending_consumed_order() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = collections::create(&database, user.id, "Home").await.unwrap();

        let older = create(
            &database,
            user.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Taganan", Some(2022)),
                consumed_at: "2025-01-15T19:30:00Z".to_string(),
                venue_name: Some("Home".to_string()),
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(4),
            },
        )
        .await
        .unwrap();

        let newer = create(
            &database,
            user.id,
            collection.id,
            CreateEntryInput {
                wine: sample_wine_input("Benje", Some(2023)),
                consumed_at: "2025-01-20T19:30:00Z".to_string(),
                venue_name: Some("Restaurant".to_string()),
                location_text: None,
                pairing_notes: None,
                tasting_notes: None,
                rating: Some(5),
            },
        )
        .await
        .unwrap();

        let entries = list_for_collection(&database, user.id, collection.id)
            .await
            .expect("entries should list");

        assert_eq!(entries.len(), 2);
        assert_eq!(entries[0].id, newer.id);
        assert_eq!(entries[1].id, older.id);
    }

    #[tokio::test]
    async fn rejects_listing_entries_for_non_member() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let stranger = register_user(&database).await;
        let collection = collections::create(&database, owner.id, "Home").await.unwrap();

        let result = list_for_collection(&database, stranger.id, collection.id).await;

        assert_eq!(result, Err(EntryError::Forbidden));
    }

    fn sample_wine_input(name: &str, vintage: Option<i32>) -> WineInput {
        WineInput {
            producer: Some("Envinate".to_string()),
            name: name.to_string(),
            vintage,
            style: Some("Red".to_string()),
            grape: None,
            region: None,
            country: Some("Spain".to_string()),
        }
    }

    async fn register_user(database: &sqlx::PgPool) -> crate::auth::AuthUser {
        let email = format!("{}@example.com", Uuid::new_v4().simple());

        register(
            database,
            RegisterInput {
                email,
                full_name: None,
                password: "password123".to_string(),
            },
        )
        .await
        .expect("user registration should succeed")
        .user
    }
}
