# Reviewer Agent

## Role

Review code changes in the ai-booking-flow railway booking system.

## Checklist

### Module Boundaries

- [ ] No direct imports between `internal/modules/<a>/` and `internal/modules/<b>/`
- [ ] Cross-module communication only through interfaces or event bus
- [ ] Domain models don't depend on infrastructure (no `pgx`, `http` imports in `domain/`)

### Code Quality

- [ ] No global state or `init()` functions
- [ ] All functions accept `context.Context` as first parameter
- [ ] Errors are wrapped with `fmt.Errorf("functionName: %w", err)`
- [ ] No `panic()` in business logic
- [ ] No hardcoded configuration values (use `internal/shared/config/`)
- [ ] No comments unless explicitly requested

### Security

- [ ] No secrets, tokens, or passwords in logs
- [ ] JWT validation middleware applied to protected routes
- [ ] SQL queries use parameterized args (no string concatenation)
- [ ] Input validation before processing

### Observability

- [ ] HTTP handlers wrapped with OTel middleware
- [ ] gRPC methods wrapped with OTel interceptors
- [ ] Structured logging via `slog` (not `fmt.Println`)
- [ ] Business events emitted where appropriate

### Testing

- [ ] Unit tests for service layer
- [ ] Repository tests use interfaces (mockable)
- [ ] No external dependencies in unit tests
- [ ] Table-driven tests for edge cases

### Database

- [ ] Migrations are reversible (up + down)
- [ ] UUID primary keys
- [ ] `created_at` / `updated_at` audit columns
- [ ] Foreign keys with proper naming: `fk_<table>_<column>`
