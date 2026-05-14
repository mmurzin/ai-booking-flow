# User Module

**Path**: `internal/modules/user/`

## Responsibility

Client profile management, passenger data (for booking tickets for others).

## Domain

- **Profile**: user_id (from auth), first_name, last_name, phone
- **Passenger**: full_name, document_type, document_number, birth_date

## Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/v1/users/me` | Access | Get current profile |
| PUT | `/api/v1/users/me` | Access | Update profile |
| POST | `/api/v1/users/me/passengers` | Access | Add passenger |
| GET | `/api/v1/users/me/passengers` | Access | List passengers |
| DELETE | `/api/v1/users/me/passengers/{id}` | Access | Remove passenger |

## Business Rules

- One profile per user (1:1 with auth user)
- Multiple passengers per user (for group bookings)
- Document types: passport (RU), foreign_passport, birth_certificate
- Passenger data validated before booking creation

## Dependencies

- Auth module (user_id from JWT claims, not direct import)

## Internal Structure

```
user/
├── domain/
│   ├── profile.go        # Profile model
│   ├── passenger.go      # Passenger model
│   ├── errors.go         # ErrPassengerNotFound
│   └── repository.go     # ProfileRepository, PassengerRepository
├── handler/
│   ├── rest.go           # Profile + passenger endpoints
│   └── grpc.go           # UserService gRPC
├── repository/
│   └── postgres.go       # Profile + passenger CRUD
├── service/
│   └── user.go           # Profile + passenger logic
└── module.go
```
