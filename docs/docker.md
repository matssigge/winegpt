# Docker Workflow

This project is set up to run local development, test, and build workflows through Docker Compose instead of relying on host-installed toolchains.

All Compose commands use the explicit project name `wine` to avoid collisions with containers, networks, and volumes from other repos.

## Compose files

- `compose.yml`: local development and one-off frontend build/test services
- `compose.test.yml`: isolated backend and end-to-end test stack
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
- `just backend-test`: run backend tests in the isolated test stack
- `just frontend-test`: run frontend smoke tests in a container
- `just frontend-e2e-test`: run the browser-driven auth smoke test against the isolated test stack and tear it down afterward
- `just frontend-build`: build the frontend in a container
- `just test`: run backend tests, frontend smoke tests, and the isolated browser-driven auth test
- `just down`: stop the Compose stack
- `docker compose -p wine -f compose.prod.yml up --build`: run the runtime-oriented stack

## Service ports

- Backend API: `http://127.0.0.1:3000`
- Frontend dev server: `http://127.0.0.1:5273`
- Frontend preview server: `http://127.0.0.1:4173`

PostgreSQL is published on `127.0.0.1:6432` for direct local access. Compose keeps development data in the named volume `postgres-data`.

The isolated test stack uses the separate Compose project name `wine-test`, runs a dedicated PostgreSQL instance in temporary storage, and is the only place where backend tests and Playwright tests run. It does not reuse the development database.
