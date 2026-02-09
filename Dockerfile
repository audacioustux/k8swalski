# syntax=docker/dockerfile:1

# Global args for nonroot user
ARG UID=65532
ARG GID=65532

# Planner stage - analyze dependencies
FROM chainguard/rust:latest AS planner

WORKDIR /app

# Install cargo-chef
RUN cargo install cargo-chef

# Copy manifests to create recipe
COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY src ./src

# Generate dependency recipe
RUN cargo chef prepare --recipe-path recipe.json

# Builder stage
FROM chainguard/rust:latest AS builder

ARG UID
ARG GID

WORKDIR /app

# Install cargo-chef
RUN cargo install cargo-chef

# Copy recipe from planner
COPY --from=planner /app/recipe.json recipe.json

# Build dependencies only (cached layer)
RUN --mount=type=cache,target=/home/nonroot/.cargo/registry,uid=${UID},gid=${GID},sharing=locked \
    --mount=type=cache,target=/home/nonroot/.cargo/git,uid=${UID},gid=${GID},sharing=locked \
    --mount=type=cache,target=/app/target,uid=${UID},gid=${GID} \
    cargo chef cook --release --recipe-path recipe.json

# Copy source code
COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY src ./src

# Build application with dependencies already cached
RUN --mount=type=cache,target=/home/nonroot/.cargo/registry,uid=${UID},gid=${GID},sharing=locked \
    --mount=type=cache,target=/home/nonroot/.cargo/git,uid=${UID},gid=${GID},sharing=locked \
    --mount=type=cache,target=/app/target,uid=${UID},gid=${GID} \
    cargo build --release && \
    cp target/release/k8swalski /tmp/k8swalski && \
    strip /tmp/k8swalski

# Runtime stage
FROM chainguard/wolfi-base:latest

ARG UID
ARG GID

LABEL org.opencontainers.image.title="k8swalski" \
      org.opencontainers.image.description="HTTP/HTTPS echo server for debugging and testing" \
      org.opencontainers.image.source="https://github.com/audacioustux/k8swalski" \
      org.opencontainers.image.licenses="MIT"

# Install curl for healthchecks
RUN apk add --no-cache curl

WORKDIR /app

# Copy binary from builder
COPY --from=builder /tmp/k8swalski /app/k8swalski

# Run as nonroot user
USER ${UID}:${GID}

# Expose ports
EXPOSE 8080 8443

# Run the application
ENTRYPOINT ["/app/k8swalski"]
