# Backend Agent

## Role

Implement backend features for the ai-booking-flow railway booking system.

## Tech Stack

- Go 1.23+ (target 1.25)
- Standard `net/http` for REST handlers
- gRPC for internal service communication
- PostgreSQL via `pgx/v5/pgxpool`
- `goose` for migrations
- JWT for authentication
- `log/slog` for logging
- OpenTelemetry for tracing and metrics

## Handler Conventions

### REST Handlers (`handler/rest.go`)

```go
func (h *Handler) CreateBooking(w http.ResponseWriter, r *http.Request) {
    // 1. Decode request body
    // 2. Validate input
    // 3. Call service method
    // 4. Encode response
    // 5. Handle errors with appropriate HTTP status
}
```

- Use `httputil.EncodeJSON()` and `httputil.DecodeJSON()` from `internal/shared/httputil/`
- Return errors using `httputil.RespondError(w, r, status, message)`
- Always accept `context.Context` from `r.Context()`

### gRPC Handlers (`handler/grpc.go`)

- Implement generated gRPC server interface
- Delegate business logic to service layer
- Convert domain errors to gRPC status codes

## Repository Conventions (`repository/postgres.go`)

- Accept `pgxpool.Pool` in constructor
- Use `pgx` named args where helpful
- All queries instrumented with OTel spans
- Return domain types, not database rows
- Use `database.Querier` interface from `internal/shared/database/` for testability

## Service Conventions (`service/`)

- Accept repository interfaces (from `domain/`) in constructor
- Contain all business logic
- Return domain errors defined in `domain/`
- Emit events via `events.EventBus` for cross-module communication
- Never import `repository/` or `handler/` packages

## Error Handling

```go
var (
    ErrNotFound     = errors.New("not found")
    ErrAlreadyExists = errors.New("already exists")
    ErrInvalidInput  = errors.New("invalid input")
)
```

- Define domain errors in `domain/errors.go`
- Wrap errors: `fmt.Errorf("service.CreateBooking: %w", err)`
- Map domain errors to HTTP/gRPC codes in handlers, not in services

## Logging

```go
slog.Info("booking created",
    slog.String("booking_id", id.String()),
    slog.String("user_id", userID.String()),
)
```

- Use structured logging with `slog`
- Never log sensitive data (passwords, tokens)
- Include request ID from context when available
