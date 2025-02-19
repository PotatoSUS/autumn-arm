# Build Stage for AMD64
FROM rustlang/rust:nightly-slim AS builder

WORKDIR /home/rust/src
RUN USER=root cargo new --bin autumn
WORKDIR /home/rust/src/autumn
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN apt-get update && apt-get install -y libssl-dev pkg-config && cargo install --locked --path .

# Build Stage for ARM64
FROM arm64v8/debian:bullseye-slim AS builder-arm64

WORKDIR /home/rust/src
RUN USER=root cargo new --bin autumn
WORKDIR /home/rust/src/autumn
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN apt-get update && apt-get install -y libssl-dev pkg-config && cargo install --locked --path .

# Bundle Stage
FROM arm64v8/debian:bullseye-slim

RUN apt-get update && apt-get install -y ca-certificates ffmpeg

# Copie os binários da etapa de construção AMD64
COPY --from=builder /usr/local/cargo/bin/autumn ./

EXPOSE 3000
ENV AUTUMN_HOST 0.0.0.0:3000
COPY Autumn.toml ./
CMD ["./autumn"]
