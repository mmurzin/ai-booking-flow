# Catalog Module

**Path**: `internal/modules/catalog/`

## Responsibility

Reference data: stations, routes, trains, schedules, carriages, seat maps.

## Domain

- **Station**: code, name, city, timezone
- **Route**: sequence of stations with departure/arrival times and distances
- **Train**: number, name, route, operating days
- **Schedule**: train + date + departure/arrival times per station
- **Carriage**: type, class, train_id, seat layout
- **Seat**: number, type (window/aisle/middle), position

### Carriage Types

| Type | Description | Seat Selection |
|---|---|---|
| Сидячий | Seated, no beds | Specific seat |
| Плацкарт | Open-plan, 54 beds | Specific seat |
| Купе | 4-bed compartments | Specific seat |
| СВ/Люкс | 2-bed compartments | Specific seat |

Seat selection is hybrid: all types allow specific seat selection, but the UI may default to carriage-only for плацкарт.

## Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/v1/stations` | No | List/search stations |
| GET | `/api/v1/stations/{id}` | No | Get station details |
| GET | `/api/v1/routes/{id}` | No | Get route with stations |
| GET | `/api/v1/trains/{id}` | No | Get train with carriages |
| GET | `/api/v1/schedules/{date}` | No | Get schedules for date |

## Business Rules

- Stations have unique codes (e.g., "MOW" for Moscow)
- Routes define the path: station sequence with cumulative distance
- Trains operate on specific days of the week
- Carriage pricing may differ by type and season

## Dependencies

- None (this is the base reference module)

## Internal Structure

```
catalog/
├── domain/
│   ├── station.go        # Station model
│   ├── route.go          # Route, RouteStation models
│   ├── train.go          # Train model
│   ├── schedule.go       # Schedule model
│   ├── carriage.go       # Carriage, Seat models
│   ├── errors.go         # ErrStationNotFound, etc.
│   └── repository.go     # All repository interfaces
├── handler/
│   ├── rest.go           # Catalog REST endpoints
│   └── grpc.go           # CatalogService gRPC
├── repository/
│   └── postgres.go       # Catalog CRUD + complex queries
├── service/
│   └── catalog.go        # Catalog business logic
└── module.go
```
