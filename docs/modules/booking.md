# Booking Module

**Path**: `internal/modules/booking/`

## Responsibility

Create, view, and cancel bookings. Manage tickets (seat reservations).

## Domain

- **Booking**: id, user_id, status, created_at, updated_at
- **Ticket**: booking_id, train_id, carriage_id, seat_id, passenger info, price
- **BookingStatus**: `pending` → `confirmed` → `cancelled`

### Status Machine

```
pending ──→ confirmed ──→ cancelled
  │                         ↑
  └─────────────────────────┘
```

- `pending`: created, awaiting confirmation (no payment yet)
- `confirmed`: confirmed by user or system
- `cancelled`: cancelled by user

## Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/v1/bookings` | Access | Create booking with tickets |
| GET | `/api/v1/bookings` | Access | List user's bookings |
| GET | `/api/v1/bookings/{id}` | Access | Get booking with tickets |
| POST | `/api/v1/bookings/{id}/cancel` | Access | Cancel booking |

### Create Booking Request

```json
{
  "train_id": "...",
  "date": "2026-06-15",
  "tickets": [
    {
      "carriage_id": "...",
      "seat_id": "...",
      "passenger": {
        "full_name": "Иванов Иван Иванович",
        "document_type": "passport",
        "document_number": "1234567890"
      }
    }
  ]
}
```

## Business Rules

- One booking can contain multiple tickets (group booking)
- Seat is locked (soft reservation) when booking is created
- Double-booking prevention: seat cannot be booked twice for same train+date
- Cancellation releases the seat
- Only the booking owner can view/cancel their bookings
- Events emitted: `BookingCreated`, `BookingCancelled`

## Dependencies

- **Catalog module**: validates train, carriage, seat existence (via interface)
- **Notification module**: sends email on create/cancel (via event bus)

## Internal Structure

```
booking/
├── domain/
│   ├── booking.go        # Booking model, BookingStatus
│   ├── ticket.go         # Ticket model
│   ├── events.go         # BookingCreated, BookingCancelled events
│   ├── errors.go         # ErrSeatTaken, ErrBookingNotFound, etc.
│   └── repository.go     # BookingRepository, TicketRepository
├── handler/
│   ├── rest.go           # Booking REST endpoints
│   └── grpc.go           # BookingService gRPC
├── repository/
│   └── postgres.go       # Booking + ticket CRUD, seat locking
├── service/
│   └── booking.go        # Booking business logic, event emission
└── module.go
```
