# API

## Overview

The system exposes two API interfaces:

- **REST** (external): standard HTTP JSON API for client applications
- **gRPC** (internal): protobuf-based API for service-to-service communication

## REST API

### Conventions

- Base path: `/api/v1/`
- Content-Type: `application/json`
- Authentication: Bearer token (JWT) in `Authorization` header
- Error response format:
  ```json
  {
    "error": {
      "code": "NOT_FOUND",
      "message": "booking not found"
    }
  }
  ```

### Endpoints

| Module | Method | Path | Description |
|---|---|---|---|
| Auth | POST | `/api/v1/auth/register` | Register new user |
| Auth | POST | `/api/v1/auth/login` | Login, get tokens |
| Auth | POST | `/api/v1/auth/refresh` | Refresh access token |
| User | GET | `/api/v1/users/me` | Get current user profile |
| User | PUT | `/api/v1/users/me` | Update profile |
| User | POST | `/api/v1/users/me/passengers` | Add passenger data |
| Catalog | GET | `/api/v1/stations` | List stations |
| Catalog | GET | `/api/v1/trains/{id}` | Get train with carriages |
| Search | GET | `/api/v1/search` | Search routes by from/to/date |
| Search | GET | `/api/v1/search/{id}/seats` | Get available seats |
| Booking | POST | `/api/v1/bookings` | Create booking |
| Booking | GET | `/api/v1/bookings` | List user bookings |
| Booking | GET | `/api/v1/bookings/{id}` | Get booking details |
| Booking | POST | `/api/v1/bookings/{id}/cancel` | Cancel booking |

### Health

- `GET /health/live` — liveness probe
- `GET /health/ready` — readiness probe (checks DB connection)

## gRPC API

### Conventions

- Proto files in `api/proto/`
- Separate handler files (`grpc.go`) from REST handlers
- Services map to modules: `AuthService`, `CatalogService`, `SearchService`, `BookingService`, `UserService`

### Error Mapping

| Domain Error | HTTP Status | gRPC Code |
|---|---|---|
| `ErrNotFound` | 404 | NOT_FOUND |
| `ErrAlreadyExists` | 409 | ALREADY_EXISTS |
| `ErrInvalidInput` | 400 | INVALID_ARGUMENT |
| `ErrUnauthorized` | 401 | UNAUTHENTICATED |
| `ErrForbidden` | 403 | PERMISSION_DENIED |
