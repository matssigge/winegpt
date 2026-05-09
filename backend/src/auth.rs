use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use serde::{Deserialize, Serialize};
use sqlx::{PgPool, Row};
use uuid::Uuid;

#[derive(Debug, PartialEq, Eq)]
pub enum PasswordError {
    Hash,
    InvalidHash,
}

#[derive(Debug, Deserialize)]
pub struct RegisterInput {
    pub email: String,
    pub full_name: Option<String>,
    pub password: String,
}

#[derive(Debug, Deserialize)]
pub struct LoginInput {
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize, PartialEq, Eq)]
pub struct AuthResponse {
    pub token: String,
    pub user: AuthUser,
}

#[derive(Debug, Serialize, PartialEq, Eq)]
pub struct AuthUser {
    pub id: i64,
    pub email: String,
    pub full_name: Option<String>,
    pub default_collection_id: i64,
}

#[derive(Debug, PartialEq, Eq)]
pub enum AuthError {
    InvalidEmail,
    PasswordTooShort,
    EmailTaken,
    InvalidCredentials,
    MissingSessionToken,
    Database,
    Password,
}

pub fn hash_password(password: &str) -> Result<String, PasswordError> {
    let salt = SaltString::generate(&mut OsRng);
    let password_hash = Argon2::default()
        .hash_password(password.as_bytes(), &salt)
        .map_err(|_| PasswordError::Hash)?;

    Ok(password_hash.serialize().to_string())
}

pub fn verify_password(password_hash: &str, password: &str) -> Result<bool, PasswordError> {
    let password_hash =
        PasswordHash::new(password_hash).map_err(|_| PasswordError::InvalidHash)?;

    Ok(Argon2::default()
        .verify_password(password.as_bytes(), &password_hash)
        .is_ok())
}

pub async fn register(database: &PgPool, input: RegisterInput) -> Result<AuthResponse, AuthError> {
    let email = normalize_email(&input.email).ok_or(AuthError::InvalidEmail)?;
    let full_name = normalize_full_name(input.full_name);
    validate_password(&input.password)?;

    let existing_user = sqlx::query_scalar::<_, i64>("SELECT id FROM users WHERE email = $1")
        .bind(&email)
        .fetch_optional(database)
        .await
        .map_err(|_| AuthError::Database)?;

    if existing_user.is_some() {
        return Err(AuthError::EmailTaken);
    }

    let password_hash = hash_password(&input.password).map_err(|_| AuthError::Password)?;
    let mut transaction = database.begin().await.map_err(|_| AuthError::Database)?;
    let row = sqlx::query(
        "INSERT INTO users (email, full_name, password_hash)
         VALUES ($1, $2, $3)
         RETURNING id, email, full_name",
    )
    .bind(&email)
    .bind(&full_name)
    .bind(&password_hash)
    .fetch_one(&mut *transaction)
    .await
    .map_err(|_| AuthError::Database)?;
    let user_id: i64 = row.try_get("id").map_err(|_| AuthError::Database)?;
    let user_email: String = row.try_get("email").map_err(|_| AuthError::Database)?;
    let user_full_name: Option<String> =
        row.try_get("full_name").map_err(|_| AuthError::Database)?;

    let default_collection_id =
        crate::collections::insert_with_owner(&mut transaction, user_id, "My wines")
            .await
            .map_err(|_| AuthError::Database)?;

    let token = Uuid::new_v4().simple().to_string();
    sqlx::query("INSERT INTO sessions (user_id, token) VALUES ($1, $2)")
        .bind(user_id)
        .bind(&token)
        .execute(&mut *transaction)
        .await
        .map_err(|_| AuthError::Database)?;

    transaction
        .commit()
        .await
        .map_err(|_| AuthError::Database)?;

    let user = AuthUser {
        id: user_id,
        email: user_email,
        full_name: user_full_name,
        default_collection_id,
    };

    Ok(AuthResponse { token, user })
}

pub async fn login(database: &PgPool, input: LoginInput) -> Result<AuthResponse, AuthError> {
    let email = normalize_email(&input.email).ok_or(AuthError::InvalidCredentials)?;
    let row = sqlx::query(
        "SELECT id, email, full_name, password_hash
         FROM users
         WHERE email = $1",
    )
    .bind(&email)
    .fetch_optional(database)
    .await
    .map_err(|_| AuthError::Database)?
    .ok_or(AuthError::InvalidCredentials)?;
    let password_hash: String = row
        .try_get("password_hash")
        .map_err(|_| AuthError::Database)?;
    let password_matches =
        verify_password(&password_hash, &input.password).map_err(|_| AuthError::Password)?;

    if !password_matches {
        return Err(AuthError::InvalidCredentials);
    }

    let default_collection_id = sqlx::query_scalar::<_, i64>(
        "SELECT collections.id
         FROM collections
         INNER JOIN collection_memberships
           ON collection_memberships.collection_id = collections.id
         WHERE collection_memberships.user_id = $1
           AND collection_memberships.role = 'owner'
         ORDER BY collections.created_at ASC, collections.id ASC
         LIMIT 1",
    )
    .bind(row.try_get::<i64, _>("id").map_err(|_| AuthError::Database)?)
    .fetch_optional(database)
    .await
    .map_err(|_| AuthError::Database)?
    .ok_or(AuthError::Database)?;

    let user = AuthUser {
        id: row.try_get("id").map_err(|_| AuthError::Database)?,
        email: row.try_get("email").map_err(|_| AuthError::Database)?,
        full_name: row.try_get("full_name").map_err(|_| AuthError::Database)?,
        default_collection_id,
    };
    let token = create_session(database, user.id).await?;

    Ok(AuthResponse { token, user })
}

pub async fn authenticate(database: &PgPool, token: &str) -> Result<AuthUser, AuthError> {
    if token.trim().is_empty() {
        return Err(AuthError::MissingSessionToken);
    }

    let row = sqlx::query(
        "SELECT users.id, users.email, users.full_name,
                (SELECT collections.id
                 FROM collections
                 INNER JOIN collection_memberships
                   ON collection_memberships.collection_id = collections.id
                 WHERE collection_memberships.user_id = users.id
                   AND collection_memberships.role = 'owner'
                 ORDER BY collections.created_at ASC, collections.id ASC
                 LIMIT 1) AS default_collection_id
         FROM sessions
         INNER JOIN users ON users.id = sessions.user_id
         WHERE sessions.token = $1",
    )
    .bind(token)
    .fetch_optional(database)
    .await
    .map_err(|_| AuthError::Database)?
    .ok_or(AuthError::InvalidCredentials)?;

    Ok(AuthUser {
        id: row.try_get("id").map_err(|_| AuthError::Database)?,
        email: row.try_get("email").map_err(|_| AuthError::Database)?,
        full_name: row.try_get("full_name").map_err(|_| AuthError::Database)?,
        default_collection_id: row
            .try_get::<Option<i64>, _>("default_collection_id")
            .map_err(|_| AuthError::Database)?
            .ok_or(AuthError::Database)?,
    })
}

fn normalize_email(email: &str) -> Option<String> {
    let email = email.trim().to_lowercase();

    if email.is_empty() || !email.contains('@') {
        return None;
    }

    Some(email)
}

fn normalize_full_name(full_name: Option<String>) -> Option<String> {
    full_name.and_then(|value| {
        let trimmed = value.trim().to_string();

        if trimmed.is_empty() {
            None
        } else {
            Some(trimmed)
        }
    })
}

fn validate_password(password: &str) -> Result<(), AuthError> {
    if password.len() < 8 {
        return Err(AuthError::PasswordTooShort);
    }

    Ok(())
}

async fn create_session(database: &PgPool, user_id: i64) -> Result<String, AuthError> {
    let token = Uuid::new_v4().simple().to_string();

    sqlx::query("INSERT INTO sessions (user_id, token) VALUES ($1, $2)")
        .bind(user_id)
        .bind(&token)
        .execute(database)
        .await
        .map_err(|_| AuthError::Database)?;

    Ok(token)
}

#[cfg(test)]
mod tests {
    use super::{authenticate, hash_password, login, register, verify_password, AuthError, LoginInput, RegisterInput};
    use crate::test_support::test_database;
    use uuid::Uuid;

    #[test]
    fn hashes_passwords() {
        let password_hash = hash_password("cabernet").expect("password should hash");

        assert_ne!(password_hash, "cabernet");
        assert!(password_hash.starts_with("$argon2"));
    }

    #[test]
    fn verifies_matching_password() {
        let password_hash = hash_password("cabernet").expect("password should hash");

        assert_eq!(
            verify_password(&password_hash, "cabernet").expect("password verification should work"),
            true
        );
    }

    #[test]
    fn rejects_wrong_password() {
        let password_hash = hash_password("cabernet").expect("password should hash");

        assert_eq!(
            verify_password(&password_hash, "merlot").expect("password verification should work"),
            false
        );
    }

    #[tokio::test]
    async fn rejects_short_passwords() {
        let database = test_database().await;
        let result = register(
            &database,
            RegisterInput {
                email: "a@example.com".to_string(),
                full_name: None,
                password: "short".to_string(),
            },
        )
        .await;

        assert_eq!(result, Err(AuthError::PasswordTooShort));
    }

    #[tokio::test]
    async fn rejects_invalid_email() {
        let database = test_database().await;
        let result = register(
            &database,
            RegisterInput {
                email: "invalid".to_string(),
                full_name: None,
                password: "password123".to_string(),
            },
        )
        .await;

        assert_eq!(result, Err(AuthError::InvalidEmail));
    }

    #[tokio::test]
    async fn registers_logs_in_and_authenticates_user() {
        let database = test_database().await;
        let email = format!("{}@example.com", Uuid::new_v4().simple());
        let register_response = register(
            &database,
            RegisterInput {
                email: email.clone(),
                full_name: Some("Mats".to_string()),
                password: "password123".to_string(),
            },
        )
        .await
        .expect("user registration should succeed");

        assert_eq!(register_response.user.email, email);

        let login_response = login(
            &database,
            LoginInput {
                email: email.clone(),
                password: "password123".to_string(),
            },
        )
        .await
        .expect("user login should succeed");
        let authenticated_user = authenticate(&database, &login_response.token)
            .await
            .expect("session token should authenticate");

        assert_eq!(authenticated_user.email, email);
        assert_eq!(authenticated_user.full_name, Some("Mats".to_string()));
        assert!(authenticated_user.default_collection_id > 0);
        assert_eq!(
            authenticated_user.default_collection_id,
            login_response.user.default_collection_id
        );
        assert_eq!(
            authenticated_user.default_collection_id,
            register_response.user.default_collection_id
        );
    }

    #[tokio::test]
    async fn register_creates_default_collection_named_my_wines() {
        use crate::collections;

        let database = test_database().await;
        let email = format!("{}@example.com", Uuid::new_v4().simple());
        let response = register(
            &database,
            RegisterInput {
                email: email.clone(),
                full_name: None,
                password: "password123".to_string(),
            },
        )
        .await
        .expect("registration should succeed");

        let collections = collections::list_for_user(&database, response.user.id)
            .await
            .expect("collections should list");

        assert_eq!(collections.len(), 1, "new user should own exactly one collection");
        assert_eq!(collections[0].name, "My wines");
        assert_eq!(collections[0].role, collections::CollectionRole::Owner);
    }

    #[tokio::test]
    async fn rejects_duplicate_registration() {
        let database = test_database().await;
        let email = format!("{}@example.com", Uuid::new_v4().simple());

        register(
            &database,
            RegisterInput {
                email: email.clone(),
                full_name: None,
                password: "password123".to_string(),
            },
        )
        .await
        .expect("first registration should succeed");

        let duplicate_registration = register(
            &database,
            RegisterInput {
                email,
                full_name: None,
                password: "password123".to_string(),
            },
        )
        .await;

        assert_eq!(duplicate_registration, Err(AuthError::EmailTaken));
    }
}
