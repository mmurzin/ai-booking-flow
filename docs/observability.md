# Observability

## Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Logging** | `log/slog` → Loki | Structured JSON logs |
| **Metrics** | OpenTelemetry → Prometheus | Request rates, latency, errors, DB pool |
| **Tracing** | OpenTelemetry → Jaeger | Request traces across HTTP/gRPC/DB |
| **Visualization** | Grafana | Unified dashboards |

## Architecture

```
App (OTel SDK)
  ├── HTTP middleware (otelhttp)     → Prometheus (metrics)
  │                                  → Jaeger (traces via OTLP)
  ├── gRPC interceptors (otelgrpc)   → Prometheus (metrics)
  │                                  → Jaeger (traces via OTLP)
  ├── DB queries (pgx tracing)       → Jaeger (spans)
  └── slog (structured logs)         → Loki (via Docker logging driver)
```

## Instrumentation

### HTTP Middleware Chain

```
request → recovery → logging → tracing (otelhttp) → metrics → auth → handler
```

### gRPC Interceptors

```
request → recovery → logging → tracing (otelgrpc) → metrics → handler
```

### Database

- pgx connection pool with built-in tracing support
- Each query creates a span with query text and duration

### Business Metrics

| Metric | Type | Labels |
|---|---|---|
| `booking_created_total` | Counter | `status` |
| `booking_cancelled_total` | Counter | `reason` |
| `search_requests_total` | Counter | `from_station`, `to_station` |
| `search_duration_seconds` | Histogram | - |

## Dashboards (Grafana)

### Go Runtime

- Goroutines count
- GC pause duration
- Memory allocation
- CPU usage

### HTTP/gRPC

- Request rate (RPS)
- Latency (p50, p95, p99)
- Error rate by status code
- Active requests

### Business

- Bookings created/cancelled over time
- Search popularity by route
- Seat utilization

## Health Checks

- `GET /health/live` — process is alive (no dependencies)
- `GET /health/ready` — ready to serve (DB connected, migrations applied)
- Both return `200 OK` with `{"status": "ok"}`

## Running

```bash
make docker-up-full    # app + postgres + prometheus + grafana + jaeger + loki
```

Access:
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Jaeger: http://localhost:16686
