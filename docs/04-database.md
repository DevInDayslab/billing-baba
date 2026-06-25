# Database

## Database Overview

Billing Baba uses two databases: SQLite for local offline storage and PostgreSQL for cloud sync and backup.

### Local — SQLite

| Property | Value |
|----------|-------|
| Engine | SQLite |
| ORM | Drift |
| Location | Client device |
| Purpose | Offline-first local data store |

### Cloud — PostgreSQL

| Property | Value |
|----------|-------|
| Engine | PostgreSQL |
| ORM | Drizzle |
| Hosting | <!-- TBD --> |
| Purpose | Cloud backup, synchronization, multi-device sync |

## Tables

> Schema design is pending. Copy the template below for each table when defined.

#### `<table_name>`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | | No | Primary key |
| `created_at` | | No | Created timestamp |
| `updated_at` | | No | Updated timestamp |

**Indexes:**

## Relationships

| From | To | Type | Description |
|------|----|------|-------------|
| | | 1:N / N:M / 1:1 | |

## Migration Notes

- **Local (Drift):** <!-- TBD -->
- **Cloud (Drizzle):** <!-- TBD -->
- Never edit applied migrations — create a new one instead.

Document breaking schema changes in [09-decisions.md](09-decisions.md).
