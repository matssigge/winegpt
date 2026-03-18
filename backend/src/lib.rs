pub mod auth;
pub mod collections;
pub mod db;
pub mod wines;
#[cfg(test)]
pub mod test_support;

use serde::Serialize;
use std::net::{AddrParseError, SocketAddr};

#[derive(Debug, Serialize, PartialEq, Eq)]
pub struct HealthResponse {
    pub status: &'static str,
    pub app: &'static str,
}

pub fn health_response() -> HealthResponse {
    HealthResponse {
        status: "ok",
        app: "wine",
    }
}

pub fn backend_bind_address(bind_address: Option<&str>) -> Result<SocketAddr, AddrParseError> {
    bind_address
        .unwrap_or("127.0.0.1:3000")
        .parse::<SocketAddr>()
}

pub fn database_url(database_url: Option<&str>) -> Result<&str, ConfigError> {
    database_url.ok_or(ConfigError::MissingDatabaseUrl)
}

pub fn allowed_frontend_origins(frontend_origins: Option<&str>) -> Vec<String> {
    frontend_origins
        .unwrap_or(
            "http://127.0.0.1:5273,http://localhost:5273,http://frontend:5273,http://127.0.0.1:4173,http://localhost:4173",
        )
        .split(',')
        .filter_map(|origin| {
            let trimmed = origin.trim();

            if trimmed.is_empty() {
                None
            } else {
                Some(trimmed.to_string())
            }
        })
        .collect()
}

#[derive(Debug, PartialEq, Eq)]
pub enum ConfigError {
    MissingDatabaseUrl,
}

#[cfg(test)]
mod tests {
    use super::{
        allowed_frontend_origins, backend_bind_address, database_url, health_response, ConfigError,
    };

    #[test]
    fn returns_expected_health_payload() {
        let response = health_response();

        assert_eq!(response.status, "ok");
        assert_eq!(response.app, "wine");
    }

    #[test]
    fn uses_default_bind_address() {
        let address = backend_bind_address(None).expect("default bind address should parse");

        assert_eq!(address, "127.0.0.1:3000".parse().unwrap());
    }

    #[test]
    fn parses_custom_bind_address() {
        let address = backend_bind_address(Some("0.0.0.0:4000"))
            .expect("custom bind address should parse");

        assert_eq!(address, "0.0.0.0:4000".parse().unwrap());
    }

    #[test]
    fn returns_database_url_from_config() {
        let url = database_url(Some("postgres://wine:wine@postgres:5432/wine"))
            .expect("database url should be present");

        assert_eq!(url, "postgres://wine:wine@postgres:5432/wine");
    }

    #[test]
    fn rejects_missing_database_url() {
        let error = database_url(None).expect_err("missing database url should fail");

        assert_eq!(error, ConfigError::MissingDatabaseUrl);
    }

    #[test]
    fn returns_default_frontend_origins() {
        let origins = allowed_frontend_origins(None);

        assert!(origins.contains(&"http://127.0.0.1:5273".to_string()));
        assert!(origins.contains(&"http://frontend:5273".to_string()));
    }

    #[test]
    fn parses_custom_frontend_origins() {
        let origins = allowed_frontend_origins(Some("http://a.test, http://b.test "));

        assert_eq!(
            origins,
            vec!["http://a.test".to_string(), "http://b.test".to_string()]
        );
    }
}
