use serde::{Deserialize, Serialize};
use sqlx::{PgPool, Row};

#[derive(Debug, PartialEq, Eq)]
pub enum CollectionError {
    InvalidName,
    InvalidEmail,
    AlreadyMember,
    Forbidden,
    UserNotFound,
    Database,
}

#[derive(Debug, Deserialize)]
pub struct CreateCollectionInput {
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct InviteCollectionInput {
    pub email: String,
}

#[derive(Debug, PartialEq, Eq, Serialize)]
pub struct Collection {
    pub id: i64,
    pub name: String,
    pub role: CollectionRole,
}

#[derive(Debug, PartialEq, Eq, Serialize)]
pub struct InvitedCollectionMember {
    pub user_id: i64,
    pub email: String,
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

    let collection_id = insert_with_owner(&mut transaction, user_id, &name).await?;

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

/// Inserts a collection row and an owner membership row within the supplied transaction.
/// The caller is responsible for committing or rolling back the transaction.
/// `name` must be non-empty and already normalized; this function does not validate it.
pub async fn insert_with_owner(
    transaction: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    user_id: i64,
    name: &str,
) -> Result<i64, CollectionError> {
    let collection_id = sqlx::query_scalar::<_, i64>(
        "INSERT INTO collections (name)
         VALUES ($1)
         RETURNING id",
    )
    .bind(name)
    .fetch_one(&mut **transaction)
    .await
    .map_err(|_| CollectionError::Database)?;

    sqlx::query(
        "INSERT INTO collection_memberships (collection_id, user_id, role)
         VALUES ($1, $2, 'owner')",
    )
    .bind(collection_id)
    .bind(user_id)
    .execute(&mut **transaction)
    .await
    .map_err(|_| CollectionError::Database)?;

    Ok(collection_id)
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

pub async fn require_membership(
    database: &PgPool,
    user_id: i64,
    collection_id: i64,
) -> Result<CollectionRole, CollectionError> {
    membership_role(database, user_id, collection_id)
        .await?
        .ok_or(CollectionError::Forbidden)
}

pub async fn invite_by_email(
    database: &PgPool,
    owner_user_id: i64,
    collection_id: i64,
    email: &str,
) -> Result<InvitedCollectionMember, CollectionError> {
    let email = normalize_email(email).ok_or(CollectionError::InvalidEmail)?;
    let role = require_membership(database, owner_user_id, collection_id).await?;

    if role != CollectionRole::Owner {
        return Err(CollectionError::Forbidden);
    }

    let user_row = sqlx::query("SELECT id, email FROM users WHERE email = $1")
        .bind(&email)
        .fetch_optional(database)
        .await
        .map_err(|_| CollectionError::Database)?
        .ok_or(CollectionError::UserNotFound)?;
    let invited_user_id = user_row
        .try_get("id")
        .map_err(|_| CollectionError::Database)?;
    let invited_email = user_row
        .try_get("email")
        .map_err(|_| CollectionError::Database)?;

    let existing_role = membership_role(database, invited_user_id, collection_id).await?;

    if existing_role.is_some() {
        return Err(CollectionError::AlreadyMember);
    }

    sqlx::query(
        "INSERT INTO collection_memberships (collection_id, user_id, role)
         VALUES ($1, $2, 'member')",
    )
    .bind(collection_id)
    .bind(invited_user_id)
    .execute(database)
    .await
    .map_err(|_| CollectionError::Database)?;

    Ok(InvitedCollectionMember {
        user_id: invited_user_id,
        email: invited_email,
        role: CollectionRole::Member,
    })
}

fn normalize_name(name: &str) -> Option<String> {
    let trimmed = name.trim();

    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

fn normalize_email(email: &str) -> Option<String> {
    let email = email.trim().to_lowercase();

    if email.is_empty() || !email.contains('@') {
        None
    } else {
        Some(email)
    }
}

async fn membership_role(
    database: &PgPool,
    user_id: i64,
    collection_id: i64,
) -> Result<Option<CollectionRole>, CollectionError> {
    let role = sqlx::query_scalar::<_, String>(
        "SELECT role
         FROM collection_memberships
         WHERE collection_id = $1 AND user_id = $2",
    )
    .bind(collection_id)
    .bind(user_id)
    .fetch_optional(database)
    .await
    .map_err(|_| CollectionError::Database)?;

    role.map(|role| CollectionRole::from_db(&role)).transpose()
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
    use super::{
        create, invite_by_email, list_for_user, require_membership, CollectionError,
        CollectionRole,
    };
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

        // first_user has: "My wines" (auto-created on register), "First", and "Second" (shared)
        assert_eq!(collections.len(), 3);
        assert_eq!(collections[1].id, first_collection.id);
        assert_eq!(collections[1].role, CollectionRole::Owner);
        assert_eq!(collections[2].id, second_collection.id);
        assert_eq!(collections[2].role, CollectionRole::Member);
    }

    #[tokio::test]
    async fn requires_membership_for_collection_access() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let stranger = register_user(&database).await;
        let collection = create(&database, owner.id, "Shared").await.unwrap();

        let access = require_membership(&database, stranger.id, collection.id).await;

        assert_eq!(access, Err(CollectionError::Forbidden));
    }

    #[tokio::test]
    async fn owner_can_invite_existing_user_by_email() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let invited_user = register_user(&database).await;
        let collection = create(&database, owner.id, "Shared").await.unwrap();

        let invited_member =
            invite_by_email(&database, owner.id, collection.id, &invited_user.email)
                .await
                .expect("invite should succeed");

        assert_eq!(invited_member.user_id, invited_user.id);
        assert_eq!(invited_member.email, invited_user.email);
        assert_eq!(invited_member.role, CollectionRole::Member);

        let access = require_membership(&database, invited_user.id, collection.id)
            .await
            .expect("invited user should gain collection access");
        assert_eq!(access, CollectionRole::Member);
    }

    #[tokio::test]
    async fn rejects_inviting_existing_member() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let invited_user = register_user(&database).await;
        let collection = create(&database, owner.id, "Shared").await.unwrap();

        invite_by_email(&database, owner.id, collection.id, &invited_user.email)
            .await
            .expect("first invite should succeed");
        let result = invite_by_email(&database, owner.id, collection.id, &invited_user.email).await;

        assert_eq!(result, Err(CollectionError::AlreadyMember));
    }

    #[tokio::test]
    async fn rejects_non_owner_invites() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let member = register_user(&database).await;
        let invitee = register_user(&database).await;
        let collection = create(&database, owner.id, "Shared").await.unwrap();

        sqlx::query(
            "INSERT INTO collection_memberships (collection_id, user_id, role)
             VALUES ($1, $2, 'member')",
        )
        .bind(collection.id)
        .bind(member.id)
        .execute(&database)
        .await
        .expect("member should be added");

        let result = invite_by_email(&database, member.id, collection.id, &invitee.email).await;

        assert_eq!(result, Err(CollectionError::Forbidden));
    }

    #[tokio::test]
    async fn rejects_invites_for_unknown_email() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let collection = create(&database, owner.id, "Shared").await.unwrap();

        let result =
            invite_by_email(&database, owner.id, collection.id, "missing@example.com").await;

        assert_eq!(result, Err(CollectionError::UserNotFound));
    }

    #[tokio::test]
    async fn rejects_invalid_invite_email() {
        let database = test_database().await;
        let owner = register_user(&database).await;
        let collection = create(&database, owner.id, "Shared").await.unwrap();

        let result = invite_by_email(&database, owner.id, collection.id, "not-an-email").await;

        assert_eq!(result, Err(CollectionError::InvalidEmail));
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
