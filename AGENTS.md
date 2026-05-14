# AGENTS.md — ai-booking-flow

## Project Overview

Railway ticket booking system (modular monolith).
Go module: `github.com/mmurzin/ai-booking-flow`

## Architecture

- **Modular monolith** with clean architecture inside each module
- **Ports & Adapters**: modules communicate only through Go interfaces
- **No direct imports** between modules — use interfaces defined in the consuming module's `domain/` package
- **Event bus** (`internal/shared/events/`) for async cross-module communication

## Stack

- Go 1.23+ (target 1.25)
- Standard `net/http` for REST
- gRPC with separate handlers from REST
- PostgreSQL via `pgx/v5/pgxpool`
- `goose` for migrations
- JWT (access + refresh tokens)
- OpenTelemetry (traces + metrics) → Prometheus + Jaeger
- `log/slog` structured logging → Loki
- Docker Compose for local development

## Modules

| Module | Path | Description |
|---|---|---|
| auth | `internal/modules/auth/` | Registration, login, JWT |
| user | `internal/modules/user/` | Client profiles, passenger data |
| catalog | `internal/modules/catalog/` | Stations, routes, trains, schedules, carriages |
| search | `internal/modules/search/` | Route search, seat availability |
| booking | `internal/modules/booking/` | Create/cancel bookings, tickets |
| notification | `internal/modules/notification/` | Email notifications (stub/log) |

## Module Internal Structure

Each module follows:
```
module/
├── domain/        # Models, interfaces (ports), domain errors
├── handler/       # REST (rest.go) and gRPC (grpc.go) handlers
├── repository/    # PostgreSQL implementations (adapters)
├── service/       # Business logic
└── module.go      # DI container, registers routes and services
```

## Coding Conventions

- Package naming: lowercase, single word, no underscores
- File naming: `rest.go`, `grpc.go`, `postgres.go`, `service.go` inside module subpackages
- Error handling: wrap errors with `fmt.Errorf("functionName: %w", err)`
- Context: always pass `context.Context` as first parameter
- No global state; use dependency injection
- No `init()` functions
- Use `log/slog` for all logging
- UUIDs for primary keys
- Snake_case for database columns, camelCase for JSON, PascalCase for Go

## Observability

- All HTTP handlers: wrapped with OTel middleware (metrics + tracing)
- All gRPC methods: wrapped with OTel interceptors
- All DB queries: instrumented with pgx tracing
- Health checks: `GET /health/live` (liveness), `GET /health/ready` (readiness)
- Graceful shutdown with 10s timeout

## Commands

```bash
make tools            # Download all tools to bin/
make dev              # Run with hot reload (air)
make build            # Build binary
make test             # Run tests
make lint             # Run golangci-lint
make fmt              # Run gofumpt
make proto            # Generate protobuf code
make migrate-up       # Apply migrations
make migrate-down     # Rollback migrations
make migrate-create   # Create new migration (NAME=xxx)
make docker-up        # Start app + postgres
make docker-up-full   # Start with observability stack
make docker-down      # Stop all
```

## Testing

- Unit tests: `_test.go` alongside source files
- Integration tests: `testdata/` with test SQL fixtures
- Mocks: generated via `mockery`
- Run: `make test`
