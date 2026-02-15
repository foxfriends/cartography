use super::ApiError;
use axum::http::StatusCode;

#[derive(Debug, derive_more::Display, derive_more::Error)]
#[display("permission required")]
pub struct ForbiddenError;

impl ApiError for ForbiddenError {
    const STATUS: StatusCode = StatusCode::FORBIDDEN;
    const CODE: &str = "Forbidden";
    type Detail = ();

    fn detail(&self) -> Self::Detail {}
}
