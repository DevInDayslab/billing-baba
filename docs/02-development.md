# Development

## Repository Structure

```
billing-baba/
├── apps/
│   ├── client/        # Flutter app (desktop + mobile)
│   └── api/           # Fastify REST API
├── docs/              # Project documentation
├── scripts/           # Automation scripts
├── .github/           # PR template, issue templates, CI workflows
└── .cursor/           # Cursor configuration
```

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | Latest stable |
| Bun | Latest |
| Git | Latest |
| Cursor | Latest |
| NeonDB | PostgreSQL 15+ (cloud) |

## Setup

1. Clone the repository and enter the monorepo root.

2. **API** — from `apps/api/`:

   ```bash
   bun install
   cp .env.example .env
   # Set DATABASE_URL to your NeonDB connection string
   ```

3. **Database** — apply schema to NeonDB:

   ```bash
   bun run db:generate   # after schema changes — creates migration SQL
   bun run db:migrate    # apply migrations
   # OR for local dev only:
   bun run db:push       # push schema without migration files
   bun run db:seed       # optional dev seed data
   ```

4. **Client** — from `apps/client/`:

   ```bash
   flutter pub get
   ```

For Git workflow, see [07-git-workflow.md](07-git-workflow.md).

## Useful Commands

### API (`apps/api/`)

| Command | Description |
|---------|-------------|
| `bun run dev` | Start Fastify dev server (tsx watch) |
| `bun run build` | Compile TypeScript |
| `bun run start` | Run compiled server |
| `bun run lint` | ESLint |
| `bun run format` | Prettier |
| `bun run db:generate` | Drizzle Kit — generate migration from schema |
| `bun run db:migrate` | Apply migrations to NeonDB |
| `bun run db:push` | Push schema directly (dev only) |
| `bun run db:studio` | Drizzle Studio (inspect data) |
| `bun run db:seed` | Seed demo business data |

Schema source of truth: [04-database.md](04-database.md). Drizzle definitions live in `apps/api/src/db/schema/`.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | NeonDB PostgreSQL connection string |

Never commit `.env` files.

## Development Workflow

1. Pick up a task from ClickUp.
2. Create a feature branch from `develop` — see [07-git-workflow.md](07-git-workflow.md).
3. Implement and test locally.
4. Open a Pull Request to `develop`.
5. Address review feedback and merge after approval.

## Troubleshooting

Add issues here as they come up.

| Problem | Solution |
|---------|----------|
| Dependencies fail to install | |
| Server won't start | |
| Tests fail locally | |
