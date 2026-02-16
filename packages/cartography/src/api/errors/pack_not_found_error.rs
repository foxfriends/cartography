use super::ApiError;
use axum::http::StatusCode;

#[derive(Debug, derive_more::Display, derive_more::Error)]
#[display("a pack with id {pack_id} was not found")]
pub struct PackNotFoundError {
    pub pack_id: i64,
}

impl ApiError for PackNotFoundError {
    const STATUS: StatusCode = StatusCode::NOT_FOUND;
    const CODE: &str = "PackNotFound";
    type Detail = ();

    fn detail(&self) -> Self::Detail {}
}
