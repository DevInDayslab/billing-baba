# Billing Baba API

Fastify REST API for auth, cloud sync, and backup. Business operations run offline on the Flutter client; this service handles cloud-side concerns only.

**Stack:** Bun · TypeScript · Fastify · PostgreSQL (Neon) · Drizzle ORM · Zod

## Prerequisites

- [Bun](https://bun.sh/) (latest)
- Neon PostgreSQL connection string (when connecting to the shared development database)

No local PostgreSQL installation is required.

## Setup

```bash
bun install
cp .env.example .env
```

Required environment variables (application fails at startup if missing):

| Variable | Description |
|----------|-------------|
| `APP_NAME` | Application display name |
| `NODE_ENV` | `development`, `production`, or `test` |
| `HOST` | Bind address (e.g. `0.0.0.0`) |
| `PORT` | HTTP port |
| `API_PREFIX` | Versioned API prefix (e.g. `/api/v1`) |
| `LOG_LEVEL` | Pino log level |

Optional:

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | Neon PostgreSQL connection string |
| `JWT_SECRET` | Access token signing secret |
| `JWT_REFRESH_SECRET` | Refresh token signing secret |
| `MSG91_AUTH_KEY` | MSG91 server auth key for OTP verification |
| `ENABLE_DEV_LOGIN` | `true` to register `POST /auth/dev-login` locally; **must be `false` in production** |
| `CORS_ORIGINS` | Comma-separated allowed origins (production) |

## Development Login

For local development only, you can bypass MSG91 OTP and sign in instantly.

Set `ENABLE_DEV_LOGIN=true` in `apps/api/.env`. When enabled, the API registers `POST /api/v1/auth/dev-login`, which:

- Finds or creates a dedicated development account and business (reused on subsequent calls)
- Issues real JWT access and refresh tokens — same response shape as `POST /auth/login`
- Logs `DEV LOGIN USED` when `NODE_ENV=development`

When `ENABLE_DEV_LOGIN` is not `true`, the route is **not registered**. Requests to `/auth/dev-login` receive a generic `404 Not Found` so production never reveals the feature.

**Never set `ENABLE_DEV_LOGIN=true` in production.**

## Run

| Command | Description |
|---------|-------------|
| `bun run dev` | Dev server with pretty Pino logs |
| `bun run build` | Compile TypeScript to `dist/` |
| `bun run start` | Run compiled server (JSON logs in production) |
| `bun run typecheck` | Type-check without emitting |
| `bun run lint` | Format and lint with Biome |

## API Versioning

All endpoints are versioned through the `API_PREFIX` environment variable. Never hardcode the prefix.

```
API_PREFIX=/api/v1
```

Every route — current and future — is registered under this prefix automatically via `src/modules/index.ts`. Feature work only requires changes inside the relevant module.

Examples:

| Method | Path |
|--------|------|
| GET | `/api/v1/health` |
| GET | `/api/v1/ready` |
| GET | `/api/v1/health/db` |
| POST | `/api/v1/auth/login` *(future)* |
| GET | `/api/v1/businesses` *(future)* |

Swagger UI at `/docs` uses the same `API_PREFIX` as the server URL.

## Module Registration

All feature modules are registered in `src/modules/index.ts` under `API_PREFIX`. Each module exposes a Fastify plugin from its `index.ts`:

| Module | Route prefix |
|--------|--------------|
| health | `/health`, `/ready`, `/health/db` |
| auth | `/auth` |
| business | `/businesses` |
| crm | `/crm` |
| inventory | `/inventory` |
| sales | `/sales` |
| purchases | `/purchases` |
| accounting | `/accounting` |
| reports | `/reports` |
| settings | `/settings` |
| sync | `/sync` |

New routes are added inside the module — not in `app.ts`.

## Health Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Application health |
| GET | `/api/v1/ready` | Readiness check |
| GET | `/api/v1/health/db` | Database connectivity |

## API Response Format

**Success:**

```json
{
  "success": true,
  "data": {}
}
```

**Error:**

```json
{
  "success": false,
  "message": "An unexpected error occurred",
  "code": "INTERNAL_SERVER_ERROR",
  "errors": null,
  "requestId": "req-123456"
}
```

Stack traces and database errors are never exposed to clients.

## Request IDs

Every request receives a unique ID (`req-<uuid>`) via Fastify's `genReqId`.

- Included in all request logs
- Returned in the `X-Request-Id` response header
- Included in every error response body as `requestId`
- Accessible on the server via `request.id`

## Logging

| Environment | Format |
|-------------|--------|
| Development | Pretty-printed (pino-pretty) |
| Production | Structured JSON |

Each request log includes: `requestId`, `method`, `path`, `statusCode`, `duration`.

`userId` and `businessId` will be added once authentication is implemented.

## Graceful Shutdown

On `SIGINT` or `SIGTERM`:

1. Stop accepting new requests
2. Close Fastify (drain in-flight requests)
3. Close Drizzle/Postgres connections
4. Flush the logger
5. Exit cleanly

Each step is logged. Duplicate signals during shutdown are ignored.

## Database Commands

| Command | Description |
|---------|-------------|
| `bun run db:generate` | Generate migration SQL from schema changes |
| `bun run db:migrate` | Apply migrations to Neon |
| `bun run db:seed` | Seed development data |
| `bun run db:studio` | Open Drizzle Studio |

## Request Flow

```
HTTP Request → Route → Controller → Service → Repository → Drizzle ORM → PostgreSQL (Neon)
```

## Project Structure

```
src/
├── app.ts              # Fastify bootstrap
├── server.ts           # Entry point
├── shutdown.ts         # Graceful shutdown handler
├── config/app_config.ts
├── db/
├── plugins/
├── middleware/
├── modules/            # Feature plugins (registered under API_PREFIX)
└── shared/
```

See [docs/05-api.md](../../docs/05-api.md) for the API contract and [docs/04-database.md](../../docs/04-database.md) for the database schema.
