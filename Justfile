set quiet

default: dev

dev:
    npx vite dev

build:
    npx vite build

preview:
    npx vite preview

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

fix: fmt (lint "fix")
