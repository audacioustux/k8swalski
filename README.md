# k8swalski

[![Build](https://img.shields.io/github/actions/workflow/status/nobinalo/k8swalski/build-push-ghcr.yml?style=flat-square)](https://github.com/nobinalo/k8swalski/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

<!-- BEGIN_CLI_HELP -->
<!-- END_CLI_HELP -->

## Installation

### Docker

```bash
# Pull and run
docker run -p 8080:8080 -p 8443:8443 ghcr.io/nobinalo/k8swalski:latest

# Test
curl http://localhost:8080/test
```

### Docker Compose

See [docker-compose.yml](docker-compose.yml) for full example.

### Kubernetes

See [k8s/](k8s/) for deployment manifests.

## Usage

### Basic Request

```bash
curl http://localhost:8080/test
```

### Custom Response

```bash
# Custom status code
curl "http://localhost:8080/?x-set-response-status-code=404"

# Add delay
curl "http://localhost:8080/?x-set-response-delay-ms=1000"

# Custom content type
curl "http://localhost:8080/?x-set-response-content-type=text/html"
```

### POST Data

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"key":"value"}' \
  http://localhost:8080/api
```

## Development

```bash
# Setup with Nix
nix develop  # or: direnv allow

# Available tasks
task --list
```

See [Taskfile.yml](Taskfile.yml) for all development commands.

## License

[MIT](LICENSE)
