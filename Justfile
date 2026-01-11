set quiet
set dotenv-load

[group: "run"]
default: dev

[group: "dev"]
fix: fmt (lint "fix")

export CONCURRENTLY_KILL_OTHERS := "true"
export CONCURRENTLY_PAD_PREFIX := "true"
export CONCURRENTLY_PREFIX_COLORS := "auto"

DATABASE_URL := env_var("DATABASE_URL")
SHADOW_DATABASE_URL := env_var("SHADOW_DATABASE_URL")
ROOT_DATABASE_URL := env_var("ROOT_DATABASE_URL")

database_name := if DATABASE_URL != "" { file_stem(DATABASE_URL) } else { "" }
shadow_database_name := if SHADOW_DATABASE_URL != "" { file_stem(SHADOW_DATABASE_URL) } else { "" }

[group: "run"]
dev: up
    npx concurrently --names "sveltekit,migrate,server" \
        "npx vite dev --host" \
        "npx graphile-migrate watch" \
        "cd server && gleam run"

[group: "run"]
app: up
    npx concurrently --names "sveltekit,migrate,server,tauri" \
        "npx vite dev --host" \
        "npx graphile-migrate watch" \
        "cd server && gleam run" \
        "npx tauri dev"

[group: "dev"]
init: get
    cp .env.example .env.local
    cd .git/hooks && ln -sf ../../.hooks/* .
    if [ ! -f .env ]; then ln -s .env.local .env; fi
    just up

[group: "dev"]
get:
    npm install

[group: "docker"]
up: && migrate
    docker compose up -d --wait
    docker compose exec postgres psql {{DATABASE_URL}} -c "" || docker compose exec postgres psql {{ROOT_DATABASE_URL}} -c 'CREATE DATABASE {{database_name}}'
    docker compose exec postgres psql {{SHADOW_DATABASE_URL}} -c "" || docker compose exec postgres psql {{ROOT_DATABASE_URL}} -c 'CREATE DATABASE {{shadow_database_name}}'

[group: "docker"]
down:
    docker compose down

[group: "docker"]
stop:
    docker compose stop

[group: "release"]
build:
    npx svelte-kit sync
    npx vite build

[group: "release"]
build-app:
    npx tauri build

[group: "dev"]
clean:
    rm -rf .svelte-kit build .eslintcache

[group: "dev"]
check:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json
    cd src-tauri && cargo check
    cd server && gleam check

[group: "dev"]
watch:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json --watch

[group: "dev"]
lint mode="check":
    npx eslint . {{ if mode == "fix" { "--fix" } else { "--cache" } }}
    cd src-tauri && cargo clippy

[group: "dev"]
fmt:
    npx prettier --write . --cache
    cd src-tauri && cargo fmt
    cd server && gleam format

[group: "dev"]
test:
    npm test
    cd server && gleam test
    cd src-tauri && cargo test

[group: "database"]
migrate:
    npx graphile-migrate migrate --forceActions

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
