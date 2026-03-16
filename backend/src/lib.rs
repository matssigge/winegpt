use serde::Serialize;

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

#[cfg(test)]
mod tests {
    use super::health_response;

    #[test]
    fn returns_expected_health_payload() {
        let response = health_response();

        assert_eq!(response.status, "ok");
        assert_eq!(response.app, "wine");
    }
}
