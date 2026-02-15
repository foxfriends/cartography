use super::ApiError;
use axum::http::StatusCode;

#[derive(Debug, derive_more::Display, derive_more::Error)]
#[display("a banner with id {banner_id} was not found")]
pub struct BannerNotFoundError {
    pub banner_id: String,
}

impl ApiError for BannerNotFoundError {
    const STATUS: StatusCode = StatusCode::NOT_FOUND;
    const CODE: &str = "BannerNotFound";
    type Detail = ();

    fn detail(&self) -> Self::Detail {}
}
