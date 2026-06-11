# Notification Module

**Path**: `internal/modules/notification/`

## Responsibility

Send email notifications for booking events. Currently a stub that logs notifications instead of sending emails.

## Domain

- **Notification**: id, type, recipient, subject, body, status, created_at
- **NotificationType**: `booking_created`, `booking_cancelled`

## Events Handled

| Event | Action |
|---|---|
| `BookingCreated` | Send booking confirmation email |
| `BookingCancelled` | Send cancellation email |

## Business Rules

- Currently: log notification to stdout (structured log via slog)
- Future: SMTP or email API integration
- Interface-based design: `Notifier` interface allows easy swap

## Dependencies

- **Event bus**: subscribes to booking events
- No direct module dependencies

## Internal Structure

```
notification/
├── domain/
│   ├── notification.go   # Notification model
│   └── notifier.go       # Notifier interface
├── handler/              # No REST/gRPC endpoints (event-driven only)
│   └── .gitkeep
├── service/
│   └── email.go          # EmailNotifier (stub: slog logging)
└── module.go             # Subscribe to events, register notifier
```

## Notifier Interface

```go
type Notifier interface {
    SendBookingConfirmation(ctx context.Context, booking *BookingDetail) error
    SendBookingCancellation(ctx context.Context, booking *BookingDetail) error
}
```

## Future Integration

Replace `email.go` stub with real implementation:
- SMTP (net/smtp + template)
- Email API (SendGrid, Mailgun)
- Email template engine (text/template or html/template)
