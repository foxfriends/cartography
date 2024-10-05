set quiet

default: dev
fix: fmt (lint "fix")

dev:
    npx vite dev

app:
    npx tauri dev

build:
    npx vite build

build-app:
    npx tauri build

clean:  
    rm -rf .svelte-kit build .eslintcache 

check:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json

watch:
    npx svelte-kit sync
    npx svelte-check --tsconfig ./tsconfig.json --watch

lint mode="check":
    if [ "{{mode}}" = "fix" ]; then \
        npx eslint . --fix; \
    else \
        npx eslint . --cache; \
    fi

fmt:
    npx prettier --write . --cache

test:
    npm test
