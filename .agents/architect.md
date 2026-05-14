# Architect Agent

## Role

Make architectural decisions for the ai-booking-flow railway booking system.

## Principles

1. **Modular monolith**: each module is a bounded context with strict boundaries
2. **No cross-module imports**: modules communicate through interfaces defined in the consuming module's `domain/` package
3. **Ports & Adapters**: domain defines interfaces (ports), infrastructure implements them (adapters)
4. **Event-driven**: use `internal/shared/events/` for async cross-module communication
5. **Dependency injection**: no global state, all dependencies passed through constructors

## When Adding a New Module

1. Define bounded context boundaries clearly
2. Create directory structure: `domain/`, `handler/`, `repository/`, `service/`, `module.go`
3. Define domain models and interfaces in `domain/`
4. Module must be registerable via `module.go` (DI container)
5. Document the module in `docs/modules/<name>.md`

## When Modifying Module Boundaries

- If two modules share a domain concept, extract it to `internal/shared/domain/`
- If a module grows too large (> 15 files in `service/`), consider splitting
- Never create circular dependencies between modules

## Database Conventions

- UUID primary keys
- Snake_case column names
- Audit columns: `created_at`, `updated_at`
- Foreign keys with explicit names: `fk_<table>_<column>`
- Migrations in `internal/migrations/`, named with goose format
