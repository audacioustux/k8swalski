# syntax=docker/dockerfile:1

# Build from source
FROM rust:1.85 AS builder-source
WORKDIR /build
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release && strip target/release/k8swalski
RUN cp target/release/k8swalski /k8swalski

# Use pre-built binary (CI/CD)
FROM scratch AS builder-prebuilt
COPY artifact/k8swalski /k8swalski

# Runtime base
FROM cgr.dev/chainguard/static:latest AS runtime-base
LABEL org.opencontainers.image.title="k8swalski"
LABEL org.opencontainers.image.description="HTTP/HTTPS echo server for debugging and testing"
LABEL org.opencontainers.image.source="https://github.com/audacioustux/k8swalski"
LABEL org.opencontainers.image.licenses="MIT"
WORKDIR /app
EXPOSE 8080 8443
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 CMD ["./k8swalski", "--check-health"]
ENTRYPOINT ["./k8swalski"]

# Local development (default)
FROM runtime-base AS runtime
COPY --from=builder-source /k8swalski ./k8swalski

# CI/CD with pre-built binary
FROM runtime-base AS runtime-prebuilt
COPY --from=builder-prebuilt /k8swalski ./k8swalski
