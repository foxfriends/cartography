set quiet
set dotenv-load

default: dev
fix: fmt (lint "fix")

export CONCURRENTLY_KILL_OTHERS := "true"
export CONCURRENTLY_PAD_PREFIX := "true"
export CONCURRENTLY_PREFIX_COLORS := "auto"

DATABASE_URL := env_var("DATABASE_URL")
SHADOW_DATABASE_URL := env_var("SHADOW_DATABASE_URL")
ROOT_DATABASE_URL := env_var("ROOT_DATABASE_URL")

database_name := if DATABASE_URL != "" { file_stem(DATABASE_URL) } else { "" }
shadow_database_name := if SHADOW_DATABASE_URL != "" { file_stem(SHADOW_DATABASE_URL) } else { "" }

dev: up
    npx concurrently --names "sveltekit,migrate,server" \
        "npx vite dev --host" \
        "npx graphile-migrate watch" \
        "cd server && gleam run"

app: up
    npx concurrently --names "sveltekit,migrate,server,tauri" \
        "npx vite dev --host" \
        "npx graphile-migrate watch" \
        "cd server && gleam run" \
        "npx tauri dev"

init: get
    cp .env.example .env.local
    cd .git/hooks && ln -sf ../../.hooks/* .
    if [ ! -f .env ]; then ln -s .env.local .env; fi
    just up

get:
    npm install

up: && migrate
    docker compose up -d --wait
    docker compose exec postgres psql {{DATABASE_URL}} -c "" || docker compose exec postgres psql {{ROOT_DATABASE_URL}} -c 'CREATE DATABASE {{database_name}}'
    docker compose exec postgres psql {{SHADOW_DATABASE_URL}} -c "" || docker compose exec postgres psql {{ROOT_DATABASE_URL}} -c 'CREATE DATABASE {{shadow_database_name}}'

down:
    docker compose down

stop:
    docker compose stop

build:
    npx svelte-kit sync
    npx vite build

build-app:
    npx tauri build

clean:
    rm -rf .svelte-kit build .eslintcache

check:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json
    cd src-tauri && cargo check
    cd server && gleam check

watch:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json --watch

lint mode="check":
    npx eslint . {{ if mode == "fix" { "--fix" } else { "--cache" } }}
    cd src-tauri && cargo clippy

fmt:
    npx prettier --write . --cache
    cd src-tauri && cargo fmt
    cd server && gleam format

test:
    npm test
    cd server && gleam test
    cd src-tauri && cargo test

migrate:
    npx graphile-migrate migrate --forceActions

migration:
    npx prettier migrations -w
    npx graphile-migrate commit

_pre-commit:
    npx graphile-migrate status

[confirm]
reset:
    npx graphile-migrate reset --erase
