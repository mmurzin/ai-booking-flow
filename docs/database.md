# Database

## Overview

PostgreSQL 16+ accessed via `pgx/v5/pgxpool`.

## Connection

Connection string format:
```
postgres://<user>:<password>@<host>:<port>/<database>?sslmode=disable
```

Managed in `internal/shared/database/` — provides a configured `pgxpool.Pool`.

## Migrations

Tool: `goose`
Location: `internal/migrations/`
Format: SQL files with goose headers

### Creating a Migration

```bash
make migrate-create NAME=add_bookings
```

Creates two files:
```
internal/migrations/<timestamp>_add_bookings.up.sql
internal/migrations/<timestamp>_add_bookings.down.sql
```

### Migration Example

```sql
-- +goose Up
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    train_id UUID NOT NULL REFERENCES trains(id),
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE IF EXISTS bookings;
```

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Table names | plural, snake_case | `bookings`, `train_schedules` |
| Column names | snake_case | `created_at`, `user_id` |
| Primary keys | `id` (UUID) | `id UUID PRIMARY KEY` |
| Foreign keys | `fk_<table>_<column>` | `fk_bookings_user_id` |
| Indexes | `idx_<table>_<columns>` | `idx_bookings_user_id` |
| Unique constraints | `uniq_<table>_<columns>` | `uniq_stations_code` |

## Common Columns

All tables include:
- `id` — UUID primary key (`gen_random_uuid()`)
- `created_at` — TIMESTAMPTZ, default `now()`
- `updated_at` — TIMESTAMPTZ, default `now()`

## Entity Relationships (planned)

```
stations ──< route_stations >── routes
routes ──< train_schedules
train_schedules ──< carriages
carriages ──< seats

users ──< bookings
bookings ──< tickets
tickets ──> seats
```

## Repository Pattern

Repositories accept `pgxpool.Pool` or `database.Querier` interface:
```go
type BookingRepository interface {
    Create(ctx context.Context, booking *Booking) error
    GetByID(ctx context.Context, id uuid.UUID) (*Booking, error)
    ListByUser(ctx context.Context, userID uuid.UUID) ([]*Booking, error)
    Update(ctx context.Context, booking *Booking) error
    Delete(ctx context.Context, id uuid.UUID) error
}
```
