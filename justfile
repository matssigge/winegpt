set shell := ["zsh", "-cu"]
compose := "docker compose -p wine -f compose.yml"
compose_test := "docker compose -p wine-test -f compose.test.yml"

default:
  @just --list

install:
  {{compose}} build

backend-test:
  {{compose_test}} run --rm backend-test

backend-run:
  {{compose}} up backend

frontend-build:
  {{compose}} run --rm frontend-build

frontend-dev:
  {{compose}} up frontend

frontend-test:
  {{compose}} run --rm frontend-test

frontend-e2e-test:
  zsh -lc 'trap "docker compose -p wine-test -f compose.test.yml down -v" EXIT; docker compose -p wine-test -f compose.test.yml up --build --abort-on-container-exit --exit-code-from frontend-e2e frontend-e2e'

test: backend-test frontend-test frontend-e2e-test

build: frontend-build

dev:
  {{compose}} up

down:
  {{compose}} down
