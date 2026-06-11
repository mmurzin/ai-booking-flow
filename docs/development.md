# Development

## Prerequisites

- Go 1.23+ (target 1.25)
- PostgreSQL 16+
- Docker + Docker Compose
- protoc (for protobuf generation)

## Quick Start

```bash
make tools                        # Download all tools to bin/
make docker-up                    # Start PostgreSQL
cp .env.example .env              # Configure environment
make migrate-up                   # Apply database migrations
make dev                          # Run with hot reload (air)
```

## Available Commands

### Tools

```bash
make tools          # Download all tools to bin/
make clean-tools    # Remove bin/ directory
```

Tools installed to `bin/`:
- `air` — hot reload
- `protoc-gen-go` — protobuf Go code generation
- `protoc-gen-go-grpc` — gRPC stubs generation
- `golangci-lint` — linter
- `goose` — database migrations
- `oapi-codegen` — OpenAPI code generation
- `mockery` — mock generation
- `gofumpt` — code formatting

### Build & Run

```bash
make build          # Build binary to build/
make run            # Build and run
make dev            # Run with hot reload (air)
```

### Code Quality

```bash
make lint           # Run golangci-lint
make fmt            # Format code with gofumpt
make test           # Run all tests
```

### Database

```bash
make migrate-up                     # Apply migrations
make migrate-down                   # Rollback migrations
make migrate-create NAME=add_users  # Create new migration
```

### Docker

```bash
make docker-build     # Build Docker image
make docker-up        # Start app + postgres
make docker-up-full   # Start with observability stack
make docker-down      # Stop all
make docker-logs      # Follow app logs
```

### Code Generation

```bash
make proto             # Generate Go from .proto files
make generate-mocks    # Generate mocks with mockery
```

## Environment Variables

See `.env.example` for all available variables.

## Hot Reload

Air configuration in `.air.toml`:
- Watches `.go`, `.toml`, `.yaml`, `.sql` files
- Excludes `bin/`, `tmp/`, `vendor/`, `deployments/`, `docs/`
- Builds to `./tmp/server`
- Kill delay: 0.5s (allows graceful shutdown)

## Observability Stack

```bash
make docker-up-full
```

Services:
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- Jaeger: http://localhost:16686
