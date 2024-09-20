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

lint:
    npx eslint . --cache

fmt:
    npx prettier --write . --cache

test:
    npm test
