use serde::{Deserialize, Serialize};
use sqlx::{PgPool, Row};

#[derive(Debug, PartialEq, Eq)]
pub enum CollectionError {
    InvalidName,
    Database,
}

#[derive(Debug, Deserialize)]
pub struct CreateCollectionInput {
    pub name: String,
}

#[derive(Debug, PartialEq, Eq, Serialize)]
pub struct Collection {
    pub id: i64,
    pub name: String,
    pub role: CollectionRole,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum CollectionRole {
    Owner,
    Member,
}

pub async fn create(
    database: &PgPool,
    user_id: i64,
    name: &str,
) -> Result<Collection, CollectionError> {
    let name = normalize_name(name).ok_or(CollectionError::InvalidName)?;
    let mut transaction = database
        .begin()
        .await
        .map_err(|_| CollectionError::Database)?;

    let collection_id = sqlx::query_scalar::<_, i64>(
        "INSERT INTO collections (name)
         VALUES ($1)
         RETURNING id",
    )
    .bind(&name)
    .fetch_one(&mut *transaction)
    .await
    .map_err(|_| CollectionError::Database)?;

    sqlx::query(
        "INSERT INTO collection_memberships (collection_id, user_id, role)
         VALUES ($1, $2, 'owner')",
    )
    .bind(collection_id)
    .bind(user_id)
    .execute(&mut *transaction)
    .await
    .map_err(|_| CollectionError::Database)?;

    transaction
        .commit()
        .await
        .map_err(|_| CollectionError::Database)?;

    Ok(Collection {
        id: collection_id,
        name,
        role: CollectionRole::Owner,
    })
}

pub async fn list_for_user(
    database: &PgPool,
    user_id: i64,
) -> Result<Vec<Collection>, CollectionError> {
    let rows = sqlx::query(
        "SELECT collections.id, collections.name, collection_memberships.role
         FROM collections
         INNER JOIN collection_memberships
           ON collection_memberships.collection_id = collections.id
         WHERE collection_memberships.user_id = $1
         ORDER BY collections.created_at ASC, collections.id ASC",
    )
    .bind(user_id)
    .fetch_all(database)
    .await
    .map_err(|_| CollectionError::Database)?;

    rows.into_iter()
        .map(|row| {
            Ok(Collection {
                id: row.try_get("id").map_err(|_| CollectionError::Database)?,
                name: row.try_get("name").map_err(|_| CollectionError::Database)?,
                role: CollectionRole::from_db(
                    row.try_get("role").map_err(|_| CollectionError::Database)?,
                )?,
            })
        })
        .collect()
}

fn normalize_name(name: &str) -> Option<String> {
    let trimmed = name.trim();

    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

impl CollectionRole {
    fn from_db(role: &str) -> Result<Self, CollectionError> {
        match role {
            "owner" => Ok(Self::Owner),
            "member" => Ok(Self::Member),
            _ => Err(CollectionError::Database),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{create, list_for_user, CollectionError, CollectionRole};
    use crate::{
        auth::{register, RegisterInput},
        test_support::test_database,
    };
    use sqlx::Row;
    use uuid::Uuid;

    #[tokio::test]
    async fn creates_collection_and_owner_membership() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let collection = create(&database, user.id, "  Home cellar  ")
            .await
            .expect("collection should be created");

        assert_eq!(collection.name, "Home cellar");
        assert_eq!(collection.role, CollectionRole::Owner);

        let membership = sqlx::query(
            "SELECT role
             FROM collection_memberships
             WHERE collection_id = $1 AND user_id = $2",
        )
        .bind(collection.id)
        .bind(user.id)
        .fetch_one(&database)
        .await
        .expect("membership should exist");
        let role: String = membership.try_get("role").expect("role should be present");

        assert_eq!(role, "owner");
    }

    #[tokio::test]
    async fn rejects_blank_collection_names() {
        let database = test_database().await;
        let user = register_user(&database).await;
        let result = create(&database, user.id, "   ").await;

        assert_eq!(result, Err(CollectionError::InvalidName));
    }

    #[tokio::test]
    async fn lists_only_collections_for_the_given_user() {
        let database = test_database().await;
        let first_user = register_user(&database).await;
        let second_user = register_user(&database).await;

        let first_collection = create(&database, first_user.id, "First").await.unwrap();
        let second_collection = create(&database, second_user.id, "Second").await.unwrap();

        sqlx::query(
            "INSERT INTO collection_memberships (collection_id, user_id, role)
             VALUES ($1, $2, 'member')",
        )
        .bind(second_collection.id)
        .bind(first_user.id)
        .execute(&database)
        .await
        .expect("shared membership should be created");

        let collections = list_for_user(&database, first_user.id)
            .await
            .expect("collections should list");

        assert_eq!(collections.len(), 2);
        assert_eq!(collections[0].id, first_collection.id);
        assert_eq!(collections[0].role, CollectionRole::Owner);
        assert_eq!(collections[1].id, second_collection.id);
        assert_eq!(collections[1].role, CollectionRole::Member);
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
}
