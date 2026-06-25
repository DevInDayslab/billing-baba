# Architecture

## Overview

Billing Baba is an offline-first system with a Flutter client, Fastify REST API, and dual-database strategy. The client runs primarily on desktop (Windows, macOS) with mobile support (Android, iOS). All core business operations work locally; the API handles authentication, synchronization, cloud backup, and multi-device sync.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Flutter Client │────▶│  Fastify API    │────▶│   PostgreSQL    │
│  (Desktop +     │     │  (Auth, Sync,   │     │   (Cloud)       │
│   Mobile)       │     │   Backup)       │     │                 │
│       │         │     └─────────────────┘     └─────────────────┘
│       ▼         │
│    SQLite       │
│    (Local)      │
└─────────────────┘
```

## Folder Structure

```
billing-baba/
├── apps/
│   ├── client/        # Flutter app
│   └── api/           # Fastify REST API
├── docs/
└── scripts/
```

| Path | Purpose |
|------|---------|
| `apps/client/` | Flutter desktop and mobile application |
| `apps/api/` | Fastify REST API |
| `docs/` | Project documentation |
| `scripts/` | Automation scripts |

## Key Flows

| Flow | Steps |
|------|-------|
| Create invoice (offline) | User → Flutter Client → SQLite → Local UI update |
| Sync to cloud | Flutter Client → Fastify API → PostgreSQL |
| Multi-device sync | Device A → API → PostgreSQL → API → Device B |
| Authentication | User → Flutter Client → Fastify API → Token issued |

## Authentication Flow

1. User authenticates via the Flutter client
2. Fastify API validates credentials and issues a token
3. Client attaches credentials to sync and backup requests

See [05-api.md](05-api.md) for API-specific auth details.

## Offline Strategy

| Scenario | Behavior |
|----------|----------|
| No network on launch | App loads data from local SQLite; full POS and billing available |
| Network lost during use | Operations continue locally; changes queued for sync |
| Sync on reconnect | Client pushes pending changes to API; pulls remote updates |
