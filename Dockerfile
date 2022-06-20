############
### RUST ###
############

FROM rust:1.60-slim-bullseye as rust-base
RUN apt-get update && apt install -y --no-install-recommends ca-certificates
RUN cargo install cargo-chef
WORKDIR /app

FROM rust-base AS rust-chef
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM rust-base AS rust-build
RUN apt-get update && apt install -y --no-install-recommends protobuf-compiler
COPY --from=rust-chef /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

FROM debian:bullseye-slim AS rust-application
RUN apt-get update && apt install -y --no-install-recommends ca-certificates
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

##############
### ELIXIR ###
##############

FROM elixir:1.13.4-slim as elixir-build
RUN apt-get update && apt install -y --no-install-recommends git ca-certificates
RUN mix local.rebar --force && mix local.hex --force
ENV MIX_ENV=prod
WORKDIR /app

FROM debian:bullseye-slim AS elixir-application
RUN apt-get update && apt install -y --no-install-recommends ca-certificates
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

################
### SERVICES ###
################

# --- Database ---

FROM elixir-build as database-build
COPY . .
WORKDIR /app/database
RUN mix deps.get && mix release

FROM elixir-application AS database
COPY --from=database-build /app/database/_build .
CMD ["./prod/rel/poketwo_database/bin/poketwo_database", "start"]

# --- Gateway ---

FROM rust-build AS gateway-build
COPY . .
RUN cargo build --release --bin poketwo-gateway

FROM rust-application AS gateway
COPY --from=gateway-build /app/target/release/poketwo-gateway ./poketwo-gateway
CMD ["./poketwo-gateway"]

# --- Imgen ---

FROM rust-build AS imgen-build
COPY . .
RUN cargo build --release --bin poketwo-imgen

FROM rust-application AS imgen
COPY --from=imgen-build /app/target/release/poketwo-imgen ./poketwo-imgen
CMD ["./poketwo-imgen"]

# --- Catching Module ---

FROM rust-build AS module-catching-build
COPY . .
RUN cargo build --release --bin poketwo-module-catching

FROM rust-application AS module-catching
COPY --from=module-catching-build /app/target/release/poketwo-module-catching ./poketwo-module-catching
CMD ["./poketwo-module-catching"]

# --- General Module ---

FROM rust-build AS module-general-build
COPY . .
RUN cargo build --release --bin poketwo-module-general

FROM rust-application AS module-general
COPY --from=module-general-build /app/target/release/poketwo-module-general ./poketwo-module-general
CMD ["./poketwo-module-general"]

# --- Pokédex Module ---

FROM rust-build AS module-pokedex-build
COPY . .
RUN cargo build --release --bin poketwo-module-pokedex

FROM rust-application AS module-pokedex
COPY --from=module-pokedex-build /app/target/release/poketwo-module-pokedex ./poketwo-module-pokedex
CMD ["./poketwo-module-pokedex"]
