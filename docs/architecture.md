# Architecture

## Overview

ai-booking-flow — railway ticket booking system built as a **modular monolith** using Go.

## Architectural Style

### Modular Monolith

The application is a single deployable unit composed of independent modules with strict boundaries. Each module represents a bounded context from the domain of railway ticket booking.

### Clean Architecture (inside each module)

```
handler (delivery) → service (use cases) → domain (business logic) ← repository (infrastructure)
```

Dependencies point inward: handlers depend on services, services depend on domain interfaces, repositories implement domain interfaces.

### Ports & Adapters

- **Ports**: Go interfaces defined in each module's `domain/` package
- **Adapters**: Implementations in `repository/` (PostgreSQL), `handler/` (HTTP/gRPC)
- Modules never import each other directly — they communicate through interfaces

## Module Communication

### Synchronous (within request)

Module A needs data from Module B → Module A defines an interface in its `domain/` package → Module B provides an implementation → injected via DI.

### Asynchronous (cross-module events)

```
booking → emits BookingCreated event → event bus → notification handles event
```

Event bus lives in `internal/shared/events/`. Events are in-process (no message broker).

## Shared Kernel

`internal/shared/` contains cross-cutting concerns:

| Package | Purpose |
|---|---|
| `domain/` | Shared domain primitives (UUID, Money, etc.) |
| `events/` | Event bus, domain event interfaces |
| `database/` | PostgreSQL connection management (pgxpool) |
| `httputil/` | HTTP middleware, error handling, JSON helpers |
| `grpcutil/` | gRPC interceptors, error mapping |
| `config/` | Configuration loading (env, YAML) |
| `telemetry/` | OpenTelemetry setup (traces + metrics) |
| `logger/` | Structured logging setup (slog) |
| `health/` | Health check handlers (liveness + readiness) |

## Module List

| Module | Description |
|---|---|
| **auth** | Registration, login, JWT tokens |
| **user** | Client profiles, passenger data |
| **catalog** | Stations, routes, trains, schedules, carriages |
| **search** | Route search, seat availability |
| **booking** | Create/cancel bookings, tickets |
| **notification** | Email notifications (stub/log) |

## Key Decisions

- **Single tenant**: one organization per deployment
- **One role**: client (customer) only; admin/operator may be added later
- **No payments**: bookings without payment processing (stub for now)
- **gRPC + REST**: separate handlers, gRPC for internal calls, REST for external API
- **PostgreSQL only**: single database, no caching layer yet
