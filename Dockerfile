# syntax=docker/dockerfile:1

FROM scratch AS artifact
COPY artifact/k8swalski /k8swalski

FROM cgr.dev/chainguard/static:latest

LABEL org.opencontainers.image.title="k8swalski"
LABEL org.opencontainers.image.description="HTTP/HTTPS echo server for debugging and testing"
LABEL org.opencontainers.image.source="https://github.com/audacioustux/k8swalski"
LABEL org.opencontainers.image.licenses="MIT"

WORKDIR /app
COPY --from=artifact /k8swalski ./k8swalski

EXPOSE 8080 8443

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 CMD ["./k8swalski", "--check-health"]

ENTRYPOINT ["./k8swalski"]
