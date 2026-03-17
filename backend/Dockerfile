FROM rust:1-bookworm AS dev
WORKDIR /app

FROM rust:1-bookworm AS build
WORKDIR /app
COPY backend/Cargo.toml backend/Cargo.lock /app/backend/
COPY backend/migrations /app/backend/migrations
COPY backend/src /app/backend/src
RUN cargo build --locked --manifest-path /app/backend/Cargo.toml --release

FROM debian:bookworm-slim AS runtime
WORKDIR /app
COPY --from=build /app/backend/target/release/wine-backend /usr/local/bin/wine-backend
COPY --from=build /app/backend/migrations /app/backend/migrations
ENV BACKEND_BIND_ADDR=0.0.0.0:3000
EXPOSE 3000
CMD ["wine-backend"]
