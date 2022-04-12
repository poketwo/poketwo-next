FROM rust:1.60-slim-bullseye as chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
RUN apt-get update && apt install -y --no-install-recommends protobuf-compiler
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin poketwo-gateway

FROM debian:bullseye-slim AS gateway
RUN apt-get update && apt install -y --no-install-recommends ca-certificates
COPY --from=builder /app/target/release/poketwo-gateway ./poketwo-gateway
CMD ["./poketwo-gateway"]
