use axum::body::Body;
use axum::http::{Response, StatusCode};
use axum::response::{AppendHeaders, IntoResponse, Json};
use serde_json::Value;
use std::error::Error;

mod banner_not_found_error;
mod forbidden_error;
mod internal_server_error;
mod unauthorized_error;

pub use banner_not_found_error::BannerNotFoundError;
pub use forbidden_error::ForbiddenError;
#[allow(unused_imports)]
pub(crate) use internal_server_error::{internal_server_error, respond_internal_server_error};
pub use unauthorized_error::UnauthorizedError;

pub trait ApiError: Error {
    const STATUS: StatusCode;
    const CODE: &str;
    type Detail: serde::Serialize;

    fn headers(&self) -> AppendHeaders<Vec<(String, String)>> {
        AppendHeaders(vec![])
    }

    fn detail(&self) -> Self::Detail;
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
            self.0.headers(),
            Json(ErrorData::<T> {
                code: T::CODE,
                message: self.0.to_string(),
                detail: self.0.detail(),
            }),
        )
            .into_response()
    }
}
