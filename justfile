set shell := ["zsh", "-cu"]
compose := "docker compose -p wine -f compose.yml"

default:
  @just --list

install:
  {{compose}} build

backend-test:
  {{compose}} run --rm backend-test

backend-run:
  {{compose}} up backend

frontend-build:
  {{compose}} run --rm frontend-build

frontend-dev:
  {{compose}} up frontend

frontend-test:
  {{compose}} run --rm frontend-test

test: backend-test frontend-test

build: frontend-build

dev:
  {{compose}} up

down:
  {{compose}} down
