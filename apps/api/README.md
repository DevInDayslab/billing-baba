# Billing Baba API

Fastify REST API for auth, cloud sync, and backup. Business operations run offline on the Flutter client; this service handles cloud-side concerns only.

**Stack:** Bun · TypeScript · Fastify · PostgreSQL (NeonDB) · Drizzle ORM · Zod

## Prerequisites

- [Bun](https://bun.sh/) (latest)
- NeonDB PostgreSQL connection string (for database commands and `/health/db`)

## Setup

```bash
bun install
cp .env.example .env
# Set DATABASE_URL and other values in .env
```

## Run

| Command | Description |
|---------|-------------|
| `bun run dev` | Start dev server with hot reload (pretty Pino logs) |
| `bun run build` | Compile TypeScript to `dist/` |
| `bun run start` | Run compiled server (JSON logs in production) |
| `bun run typecheck` | Type-check without emitting |
| `bun run lint` | Format and lint with Biome |

## Database Commands

| Command | Description |
|---------|-------------|
| `bun run db:generate` | Generate migration SQL from schema changes |
| `bun run db:migrate` | Apply migrations to NeonDB |
| `bun run db:studio` | Open Drizzle Studio |

Schema source: `src/db/schema/`. Migrations: `drizzle/migrations/`.

## Health Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Application health |
| GET | `/health` | Application health |
| GET | `/ready` | Readiness check |
| GET | `/health/db` | Database connectivity (`SELECT 1`) |

Example response for `/`, `/health`, and `/ready`:

```json
{
  "status": "ok",
  "name": "Billing Baba API",
  "version": "1.0.0",
  "environment": "development",
  "uptime": 42,
  "timestamp": "2026-06-27T10:00:00.000Z"
}
```

Database health response:

```json
{ "database": "connected" }
```

Swagger UI is available at `/docs` when the server is running.

## Project Structure

```
src/
├── app.ts              # Fastify instance, plugins, middleware, routes, error handler
├── server.ts           # Entry point — config, listen, graceful shutdown
├── config/
│   └── app_config.ts   # Env-based configuration (Zod-validated)
├── db/
│   ├── client.ts       # Drizzle client and connection check
│   ├── index.ts        # Database exports
│   ├── schema/         # Drizzle table definitions
│   └── migrate.ts      # Migration runner
├── plugins/            # Fastify plugins (sensible, cors, rate-limit, swagger)
├── middleware/         # Request hooks (auth, logging — placeholders)
├── modules/
│   ├── health/         # Infrastructure health routes
│   ├── auth/           # Feature modules (empty — added in follow-up tasks)
│   ├── business/
│   ├── crm/
│   ├── inventory/
│   ├── sales/
│   ├── purchases/
│   ├── accounting/
│   ├── reports/
│   ├── settings/
│   └── sync/
└── shared/
    ├── errors/         # Application-wide error types
    └── types/          # Shared TypeScript types
```

Feature modules own their routes, services, and validation (`schemas.ts`). There are no root-level `controllers/`, `services/`, or `repositories/` folders.

## Development Workflow

1. Copy `.env.example` to `.env` and configure values.
2. Run `bun run db:migrate` to apply schema to NeonDB.
3. Run `bun run dev` — server starts on the configured host/port (defaults: `0.0.0.0:3000`).
4. Run `bun run typecheck` and `bun run lint` before pushing.

See [docs/05-api.md](../../docs/05-api.md) for the API contract and [docs/04-database.md](../../docs/04-database.md) for the database schema.
