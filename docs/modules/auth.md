# Auth Module

**Path**: `internal/modules/auth/`

## Responsibility

User registration, login, JWT token management (access + refresh).

## Domain

- **User (auth context)**: email, password hash, role
- **Token pair**: access token (short-lived, 15m), refresh token (long-lived, 7d)

## Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/v1/auth/register` | No | Register with email + password |
| POST | `/api/v1/auth/login` | No | Login, receive token pair |
| POST | `/api/v1/auth/refresh` | Refresh token | Get new access token |

## Business Rules

- Password hashed with bcrypt (cost 12)
- Access token: JWT with user_id, email, issued_at, expires_at
- Refresh token: JWT with user_id, token_id (for revocation)
- Token_id stored in DB for refresh token revocation

## Dependencies

- `internal/shared/database/` — user storage
- `internal/shared/config/` — JWT secrets, TTL config

## Internal Structure

```
auth/
├── domain/
│   ├── token.go          # Token model, claims
│   ├── errors.go         # ErrInvalidCredentials, ErrTokenExpired
│   └── repository.go     # UserRepository interface
├── handler/
│   ├── rest.go           # POST /register, /login, /refresh
│   └── grpc.go           # AuthService gRPC
├── repository/
│   └── postgres.go       # User CRUD, token storage
├── service/
│   └── auth.go           # Register, Login, RefreshToken logic
└── module.go             # DI, route registration
```
