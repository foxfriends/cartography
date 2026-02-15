use super::{ApiError, JsonError};
use axum::http::StatusCode;

#[derive(Debug, derive_more::Display, derive_more::Error)]
#[display("{_0}")]
pub struct InternalServerError(anyhow::Error);

#[allow(unused_macros)]
macro_rules! respond_internal_server_error {
    ($($fmt:tt)+) => {
        return Err(internal_server_error(anyhow::anyhow!($($fmt)+)).into())
    };
    () => {
        return Err(internal_server_error(anyhow::anyhow!("Unexpected server error")).into())
    };
}

pub(crate) use respond_internal_server_error;

pub fn internal_server_error<T>(error: T) -> JsonError<InternalServerError>
where
    anyhow::Error: From<T>,
{
    JsonError(InternalServerError(error.into()))
}

impl ApiError for InternalServerError {
    const STATUS: StatusCode = StatusCode::INTERNAL_SERVER_ERROR;
    const CODE: &str = "Internal server error";
    type Detail = ();

    fn detail(&self) -> Self::Detail {}
}
