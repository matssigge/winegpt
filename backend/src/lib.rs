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

#[derive(Debug, PartialEq, Eq)]
pub enum ConfigError {
    MissingDatabaseUrl,
}

#[cfg(test)]
mod tests {
    use super::{backend_bind_address, database_url, health_response, ConfigError};

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
}
