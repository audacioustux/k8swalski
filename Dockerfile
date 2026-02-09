# syntax=docker/dockerfile:1

ARG UID=65532
ARG GID=65532

# Builder stage
FROM chainguard/rust:latest AS builder

ARG UID
ARG GID

USER ${UID}:${GID}

WORKDIR /app

# Copy source code
COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY src ./src

# Build application
RUN --mount=type=cache,target=/home/nonroot/.cargo/registry,sharing=locked,uid=${UID},gid=${GID} \
    --mount=type=cache,target=/home/nonroot/.cargo/git,sharing=locked,uid=${UID},gid=${GID} \
    cargo build --release && strip target/release/k8swalski

# Runtime stage
FROM chainguard/wolfi-base:latest

ARG UID
ARG GID

LABEL org.opencontainers.image.title="k8swalski"
LABEL org.opencontainers.image.description="HTTP/HTTPS echo server for debugging and testing"
LABEL org.opencontainers.image.source="https://github.com/audacioustux/k8swalski"
LABEL org.opencontainers.image.licenses="MIT"

# Install curl for healthchecks
RUN apk add --no-cache curl

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/target/release/k8swalski /app/k8swalski

# Run as nonroot user
USER ${UID}:${GID}

# Expose ports
EXPOSE 8080 8443

# Run the application
ENTRYPOINT ["/app/k8swalski"]
