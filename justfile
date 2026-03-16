set shell := ["zsh", "-cu"]

default:
  @just --list

install:
  mise install
  mise exec -- npm --prefix frontend install

backend-test:
  mise exec -- cargo test --manifest-path backend/Cargo.toml

backend-run:
  mise exec -- cargo run --manifest-path backend/Cargo.toml

frontend-build:
  mise exec -- npm --prefix frontend run build

frontend-dev:
  mise exec -- npm --prefix frontend run dev

frontend-test:
  mise exec -- npm --prefix frontend run test

test: backend-test frontend-test

build: frontend-build

dev:
  @echo "Run these in separate terminals:"
  @echo "  just backend-run"
  @echo "  just frontend-dev"
