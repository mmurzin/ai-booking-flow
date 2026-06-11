# Search Module

**Path**: `internal/modules/search/`

## Responsibility

Search for available train routes by date and direction, check seat availability.

## Domain

- **SearchQuery**: from_station, to_station, date, passengers_count
- **SearchResult**: list of available trains with routes, prices, available seats
- **SeatAvailability**: train_id, carriage_id, date, available_count, seat_map

## Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/v1/search` | No | Search routes by from/to/date |
| GET | `/api/v1/search/{train_id}/seats` | No | Available seats for train + date |

### Search Parameters

```
GET /api/v1/search?from=MOW&to=LED&date=2026-06-15&passengers=2
```

Response:
```json
{
  "results": [
    {
      "train_id": "...",
      "train_number": "001А",
      "train_name": "Красная стрела",
      "departure": "2026-06-15T23:55:00+03:00",
      "arrival": "2026-06-16T07:55:00+03:00",
      "duration": "8h",
      "carriages": [
        {
          "type": "купе",
          "available_seats": 12,
          "min_price": 4500
        }
      ]
    }
  ]
}
```

## Business Rules

- Search returns trains operating on the requested date
- Availability calculated from total seats minus booked seats
- Results sorted by departure time by default
- Read-heavy module (optimized queries, possible caching later)

## Dependencies

- **Catalog module**: reads stations, routes, trains, schedules (via interface)
- **Booking module**: reads booked seats count (via interface)

## Internal Structure

```
search/
├── domain/
│   ├── search.go         # SearchQuery, SearchResult models
│   ├── errors.go         # ErrNoResults
│   └── repository.go     # CatalogReader, BookingReader interfaces
├── handler/
│   ├── rest.go           # Search endpoints
│   └── grpc.go           # SearchService gRPC
├── service/
│   └── search.go         # Search logic, availability calculation
└── module.go
```

No `repository/` package — search reads from catalog and booking through interfaces.
