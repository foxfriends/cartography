set quiet

default: dev
fix: fmt (lint "fix")

assert_env := `test -f .env`

export CONCURRENTLY_KILL_OTHERS := "true"
export CONCURRENTLY_PAD_PREFIX := "true"
export CONCURRENTLY_PREFIX_COLORS := "auto"

export DATABASE_URL := `rg '^DATABASE_URL="?([^"]*)"?$' -r '$1' .env`
export SHADOW_DATABASE_URL := `rg '^SHADOW_DATABASE_URL="?([^"]*)"?$' -r '$1' .env`
export ROOT_DATABASE_URL := `rg '^ROOT_DATABASE_URL="?([^"]*)"?$' -r '$1' .env`

database_name := file_stem(DATABASE_URL)
shadow_database_name := file_stem(SHADOW_DATABASE_URL)

dev: up
    npx concurrently --names "sveltekit,migrate" \
        "npx vite dev" \
        "npx graphile-migrate watch"

app: up
    npx concurrently --names "sveltekit,migrate,tauri" \
        "npx vite dev" \
        "npx graphile-migrate watch" \
        "npx tauri dev"

up: && migrate
    docker compose up -d --wait
    docker compose exec postgres psql {{DATABASE_URL}} -c "" || docker compose exec postgres psql {{ROOT_DATABASE_URL}} -c 'CREATE DATABASE {{database_name}}'
    docker compose exec postgres psql {{SHADOW_DATABASE_URL}} -c "" || docker compose exec postgres psql {{ROOT_DATABASE_URL}} -c 'CREATE DATABASE {{shadow_database_name}}'

down:
    docker compose down

stop:
    docker compose stop

build:
    npx vite build

build-app:
    npx tauri build

clean:
    rm -rf .svelte-kit build .eslintcache

check:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json
    npx graphile-migrate status

watch:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json --watch

lint mode="check":
    npx eslint . {{ if mode == "fix" { "--fix" } else { "--cache" } }}

fmt:
    npx prettier --write . --cache

test:
    npm test

migrate:
    npx graphile-migrate migrate

migration:
    npx prettier migrations -w
    npx graphile-migrate commit
