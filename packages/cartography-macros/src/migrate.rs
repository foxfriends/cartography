use proc_macro2::TokenStream;
use quote::quote;
use regex::Regex;
use std::sync::LazyLock;
use syn::LitStr;

static HASH_REGEX: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?m)^--! Hash: sha1:([0-9a-fA-F]+)$").unwrap());
static FILE_REGEX: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"^(\d+)(?:-(.*))?\.sql$").unwrap());

pub fn expand(path_arg: LitStr) -> Result<TokenStream, Box<dyn std::error::Error>> {
    let workspace_root = std::process::Command::new(env!("CARGO"))
        .arg("locate-project")
        .arg("--workspace")
        .arg("--message-format=plain")
        .output()
        .expect("failed to locate Cargo.toml")
        .stdout;
    let path =
        std::path::PathBuf::from(String::from_utf8(workspace_root).expect("cargo output not utf8"))
            .parent()
            .expect("Cargo.toml should be a proper path")
            .join(path_arg.value());
    let dir = std::fs::read_dir(&path)
        .map_err(|error| format!("{error}\nmigrations directory: {}", path.display()))?;
    let mut migrations = dir.filter_map(|item| item.ok()).collect::<Vec<_>>();
    migrations.sort_by_key(|item| item.file_name());
    let migrations = migrations
        .into_iter()
        .map(|item| {
            let sql = std::fs::read_to_string(item.path())?;
            let name = item.file_name();
            let name = name.to_str().expect("name is not valid");
            let file_captures = FILE_REGEX.captures(name).expect("filename is not valid");
            let version: i64 = file_captures.get(1).unwrap().as_str().parse()?;
            let description = file_captures
                .get(2)
                .map(|c| c.as_str().to_owned())
                .unwrap_or(name.to_string());
            let captures = HASH_REGEX
                .captures(&sql)
                .expect("failed to find checksum hash in file");
            let checksum: Vec<_> = hex::decode(captures.get(1).unwrap().as_str())?;
            Ok(quote! {
                sqlx::migrate::Migration {
                    version: #version,
                    description: std::borrow::Cow::Borrowed(#description),
                    migration_type: sqlx::migrate::MigrationType::Simple,
                    sql: std::borrow::Cow::Borrowed(#sql),
                    checksum: std::borrow::Cow::Borrowed(&[#(#checksum),*]),
                    no_tx: false,
                }
            })
        })
        .collect::<Result<Vec<_>, Box<dyn std::error::Error>>>()?;

    Ok(quote! {
        sqlx::migrate::Migrator {
            migrations: std::borrow::Cow::Borrowed(&[#(#migrations,)*]),
            ..sqlx::migrate::Migrator::DEFAULT
        }
    })
}
