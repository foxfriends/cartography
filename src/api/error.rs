use axum::body::Body;
use axum::http::{Response, StatusCode};
use axum::response::{IntoResponse, Json};
use serde_json::Value;
use std::error::Error;

pub trait ApiError: Error {
    const STATUS: StatusCode;
    const CODE: &str;
    type Detail: serde::Serialize;

    fn detail(&self) -> Self::Detail;
}

#[derive(Debug, derive_more::Display, derive_more::Error)]
#[display("{_0}")]
pub struct InternalServerError(anyhow::Error);

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

pub struct JsonError<T>(pub T);

impl<T: ApiError> From<T> for JsonError<T> {
    fn from(value: T) -> Self {
        Self(value)
    }
}

#[derive(utoipa::ToSchema)]
#[expect(
    dead_code,
    reason = "this is a stub type used for OpenAPI schema generation only"
)]
pub struct ErrorDetailResponse {
    code: &'static str,
    message: String,
    detail: Value,
}

impl<T: ApiError> IntoResponse for JsonError<T> {
    fn into_response(self) -> Response<Body> {
        #[derive(serde::Serialize)]
        struct ErrorData<T: ApiError> {
            code: &'static str,
            message: String,
            detail: T::Detail,
        }

        (
            T::STATUS,
            Json(ErrorData::<T> {
                code: T::CODE,
                message: self.0.to_string(),
                detail: self.0.detail(),
            }),
        )
            .into_response()
    }
}
