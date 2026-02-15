use crate::api::errors::{ForbiddenError, JsonError, UnauthorizedError};
use crate::dto::AccountIdOrMe;
use axum::extract::Request;
use axum::http::HeaderValue;
use axum::middleware::Next;
use axum::response::Response;
use axum_extra::TypedHeader;
use axum_extra::headers;
use axum_extra::headers::authorization::Credentials;

#[derive(Clone, Debug)]
pub enum Authorization {
    Unauthorized,
    AccountOwner(String),
}

impl Authorization {
    pub fn authorized_account_id(&self) -> Result<&str, JsonError<UnauthorizedError>> {
        match self {
            Authorization::Unauthorized => Err(JsonError(UnauthorizedError)),
            Authorization::AccountOwner(account_id) => Ok(account_id),
        }
    }

    pub fn resolve_account_id<'a>(
        &'a self,
        account_id: &'a AccountIdOrMe,
    ) -> Result<&'a str, JsonError<UnauthorizedError>> {
        match account_id {
            AccountIdOrMe::Me => self.authorized_account_id(),
            AccountIdOrMe::AccountId(account_id) => Ok(account_id),
        }
    }

    #[expect(clippy::result_large_err)]
    pub fn require_authorization(&self, account_id: &str) -> axum::response::Result<()> {
        let authorized_for = self.authorized_account_id()?;
        if authorized_for == account_id {
            Ok(())
        } else {
            Err(JsonError(ForbiddenError).into())
        }
    }
}

pub struct Trust(pub String);

impl Credentials for Trust {
    const SCHEME: &'static str = "Trust";

    fn decode(value: &HeaderValue) -> Option<Self> {
        Some(Self(
            value.to_str().ok()?["Trust ".len()..]
                .trim_start()
                .to_owned(),
        ))
    }

    /// Encode the credentials to a `HeaderValue`.
    ///
    /// The `SCHEME` must be the first part of the `value`.
    fn encode(&self) -> HeaderValue {
        format!("Trust {}", self.0).try_into().unwrap()
    }
}

/// DEV ONLY implementation of "authorization", in which we just trust that the caller
/// is not lying about who they are.
pub async fn trust(
    authorization: Option<TypedHeader<headers::Authorization<Trust>>>,
    mut request: Request,
    next: Next,
) -> Response {
    if let Some(TypedHeader(headers::Authorization(Trust(account_id)))) = authorization {
        request
            .extensions_mut()
            .insert(Authorization::AccountOwner(account_id));
    } else {
        request.extensions_mut().insert(Authorization::Unauthorized);
    }
    next.run(request).await
}
