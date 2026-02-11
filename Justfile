set quiet
set dotenv-load

[group: "run"]
default: dev

[group: "dev"]
fix: fmt

export TS_RS_EXPORT_DIR := "app/src/lib/appserver/types"

export CONCURRENTLY_KILL_OTHERS := "true"
export CONCURRENTLY_PAD_PREFIX := "true"
export CONCURRENTLY_PREFIX_COLORS := "auto"

DATABASE_URL := env_var("DATABASE_URL")
SHADOW_DATABASE_URL := env_var("SHADOW_DATABASE_URL")
ROOT_DATABASE_URL := env_var("ROOT_DATABASE_URL")

database_name := if DATABASE_URL != "" { file_stem(DATABASE_URL) } else { "" }
shadow_database_name := if SHADOW_DATABASE_URL != "" { file_stem(SHADOW_DATABASE_URL) } else { "" }

[group: "run"]
dev: up generate
    npx concurrently -n "server,client" \
        "cargo run" \
        "cd app && npx vite dev"

[group: "dev"]
init: get
    cp -n .env.example .env.local
    cd .git/hooks && ln -sf ../../.hooks/* .
    if [ ! -f .env ]; then ln -s .env.local .env; fi
    just up

[group: "docker"]
up: && migrate
    docker compose up -d --wait
    docker compose exec postgres psql -U postgres -d "{{database_name}}" -c "" || docker compose exec postgres psql -U postgres -c 'CREATE DATABASE {{database_name}}'
    docker compose exec postgres psql -U postgres -d "{{shadow_database_name}}" -c "" || docker compose exec postgres psql -U postgres -c 'CREATE DATABASE {{shadow_database_name}}'

[group: "dev"]
get:
    mise install
    cargo install sqruff --locked
    cargo install --git https://github.com/jflessau/sqlx-fmt --locked
    cd app && npm ci

[group: "docker"]
down:
    docker compose down

[group: "docker"]
stop:
    docker compose stop

[group: "dev"]
clean:
    cargo clean

[group: "dev"]
check:
    cargo check
    cd app && npx svelte-kit sync
    cd app && npx svelte-check

[group: "dev"]
generate:
    cargo test export_bindings
    cd app && npx svelte-kit sync
    cd app && npx prettier --write ../{{TS_RS_EXPORT_DIR}}

[group: "dev"]
fmt:
    sqlx-fmt format
    cargo fmt
    cd app && npx prettier --write .

[group: "dev"]
test:
    cargo test

[group: "database"]
migrate:
    npx graphile-migrate migrate --forceActions

[group: "database"]
migration-dev:
    npx graphile-migrate watch

[group: "database"]
migration:
    npx prettier migrations -w
    npx graphile-migrate commit

[group: "database"]
unmigration:
    npx graphile-migrate uncommit

_pre-commit:
    npx graphile-migrate status

[confirm]
[group: "database"]
reset: up
    npx graphile-migrate reset --erase

[group: "database"]
db: up
    docker compose exec postgres psql {{DATABASE_URL}}

[group: "database"]
seed:
    trilogy run ./seeds/seed.tri

[group: "database"]
apply-seed:
    trilogy run ./seeds/seed.tri | docker compose exec -T postgres psql {{DATABASE_URL}}
