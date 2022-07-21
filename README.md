# poketwo-next

[![Build](https://github.com/poketwo/poketwo-next/actions/workflows/build.yml/badge.svg)](https://github.com/poketwo/poketwo-next/actions/workflows/build.yml) [![Crowdin](https://badges.crowdin.net/poketwo/localized.svg)](https://crowdin.com/project/poketwo) [![Dependencies](https://deps.rs/repo/github/poketwo/poketwo-next/status.svg)](https://deps.rs/repo/github/poketwo/poketwo-next)

Pokétwo brings the Pokémon experience to Discord. Catch randomly-spawning pokémon in your servers, trade them to expand your collection, battle with your friends to win rewards, and more.

This repository hosts the code for Pokétwo's rewrite, which is still in progress, expected to be released in August 2022. Looking for the stable version of Pokétwo? [Click here.](https://github.com/poketwo/poketwo)

## Components

Pokétwo is a collection of smaller components:

### Supporting Services

These services handle important tasks and are relied on by other modules.

- [`database`](database) — handles database operations, accepts GRPC requests
- [`gateway`](gateway) — handles connections to Discord Gateway, sends events to RabbitMQ
- [`imgen`](imgen) — handles image generation, accepts GRPC requests

### Command Modules

These services consume Discord events from RabbitMQ, including commands and messages.

- [`module-pokedex`](module-pokedex) — Pokédex and Pokémon inventory-related commands
- [`module-catching`](module-catching) — spawning and catching of Pokémon
- [`module-general`](module-general) — miscellaneous commands not belonging to any other category
- [`module-market`](module-market) — the global Pokémon marketplace
- `module-auctions` — (not yet implemented) Pokémon auction functionality
- `module-battling` — (not yet implemented) battles between trainers
- `module-shop` — (not yet implemented) the in-game item shop
- `module-quests` — (not yet implemented) daily and weekly quests

### Libraries

These components are shared code used by other services.

- [`command-framework`](command-framework) — primary slash command handler framework
- [`command-framework-macros`](command-framework-macros) — macros used for the command framework
- [`emojis`](emojis) — Pokétwo's custom emoji library
- [`gateway-client`](gateway-client) — client that consumes events from RabbitMQ
- [`i18n-rust`](i18n-rust) — enables localization of messages
- [`protobuf`](protobuf) — Protobuf declarations shared across all components
- [`protobuf-elixir`](protobuf-elixir) — generated Protobuf code for Elixir
- [`protobuf-rust`](protobuf-rust) — generated Protobuf code for Rust
- [`resources`](resources) — folder for translations and other static files

## Deploying

Deploying Pokétwo is not simple, and is not meant to be. We do not recommend attempting to build or host Pokétwo by yourself. Instead, [use this link](https://invite.poketwo.net/) to add the production Pokétwo instance to your Discord server.

If you would still like to run your own instance, perhaps for development purposes, and you know what you are doing, a sample [`docker-compose.yml`](docker-compose.yml) is provided. As of now, however, there is no other documentation or instructions for building, and no support whatsoever will be provided.

## License

This repository is licensed under the Mozilla Public License, version 2.0. If you wish to use or distribute this code, you may do so under the terms of the MPL. [The full license can be found here.](LICENSE)
