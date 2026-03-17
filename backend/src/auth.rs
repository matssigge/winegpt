use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};

#[derive(Debug, PartialEq, Eq)]
pub enum PasswordError {
    Hash,
    InvalidHash,
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

#[cfg(test)]
mod tests {
    use super::{hash_password, verify_password};

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
}
