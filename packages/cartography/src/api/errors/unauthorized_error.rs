use super::ApiError;
use axum::{http::StatusCode, response::AppendHeaders};

#[derive(Debug, derive_more::Display, derive_more::Error)]
#[display("authentication required")]
pub struct UnauthorizedError;

impl ApiError for UnauthorizedError {
    const STATUS: StatusCode = StatusCode::UNAUTHORIZED;
    const CODE: &str = "Unauthorized";
    type Detail = ();

    fn headers(&self) -> AppendHeaders<Vec<(String, String)>> {
        AppendHeaders(vec![("WWW-Authenticate".to_owned(), "Trust".to_owned())])
    }

    fn detail(&self) -> Self::Detail {}
}
