use serde::{Deserialize, Serialize};
use sqlx::{PgPool, Row};

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
    use super::{create_or_find, WineError, WineInput};
    use crate::test_support::test_database;

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
}
