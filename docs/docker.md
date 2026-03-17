# Docker Workflow

This project is set up to run local development, test, and build workflows through Docker Compose instead of relying on host-installed toolchains.

All Compose commands use the explicit project name `wine` to avoid collisions with containers, networks, and volumes from other repos.

## Compose files

- `compose.yml`: local development and one-off test/build services
- `compose.prod.yml`: runtime-oriented services

## Services

- `postgres`: private PostgreSQL service for backend state
- `backend`: API service connected to PostgreSQL through `DATABASE_URL`
- `frontend`: UI service

## Common commands

- `just install`: build the Docker images used for local workflows
- `just dev`: run backend and frontend together
- `just backend-run`: run only the backend service
- `just frontend-dev`: run only the frontend dev server
- `just backend-test`: run backend tests in a container
- `just frontend-test`: run frontend smoke tests in a container
- `just frontend-build`: build the frontend in a container
- `docker compose -p wine -f compose.yml run --rm frontend-e2e`: run the browser-driven auth smoke test with Playwright baked into the image
- `just down`: stop the Compose stack
- `docker compose -p wine -f compose.prod.yml up --build`: run the runtime-oriented stack

## Service ports

- Backend API: `http://127.0.0.1:3000`
- Frontend dev server: `http://127.0.0.1:5273`
- Frontend preview server: `http://127.0.0.1:4173`

PostgreSQL is intentionally not published on a host port. Compose keeps its data in the named volume `postgres-data`.
