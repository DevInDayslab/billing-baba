# Coding Standards

## General Principles

1. **Readability over cleverness**
2. **Small, focused changes** — one concern per pull request
3. **Follow existing patterns** — match the codebase before adding abstractions
4. **No dead code**
5. **Comments explain why**, not what

## Stack-Specific Guidelines

| Area | Technology | Notes |
|------|------------|-------|
| Client | Flutter | Feature-based folder structure |
| State | Riverpod | Prefer providers over manual state |
| Navigation | GoRouter | Declarative routing |
| Local DB | Drift | Type-safe SQLite queries |
| Backend | Fastify | Route handlers in feature modules |
| Cloud DB | Drizzle | Type-safe PostgreSQL queries |

## Naming

| Element | Convention | Example |
|---------|------------|---------|
| Dart files | `snake_case` | `invoice_list_screen.dart` |
| Dart classes | `PascalCase` | `InvoiceListScreen` |
| TypeScript files | `kebab-case` | `invoice-service.ts` |
| TypeScript classes | `PascalCase` | `InvoiceService` |
| Functions / Methods | `camelCase` | `getInvoiceById` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Database tables | `snake_case`, plural | `invoices` |
| API routes | `kebab-case` | `/api/invoices` |

## Folder Rules

- **Client:** Group by feature (`features/invoices/`, `features/products/`)
- **API:** Group by domain (`routes/`, `services/`, `db/`)
- Shared utilities in `shared/` or `common/`
- Pick one test location per app and stay consistent

## Code Style

| Tool | Config | Command |
|------|--------|---------|
| Dart analyzer | `analysis_options.yaml` | `flutter analyze` |
| Dart formatter | `analysis_options.yaml` | `dart format .` |
| ESLint | `apps/api/` | <!-- TBD --> |
| Prettier | `apps/api/` | <!-- TBD --> |

- Run linter and formatter before pushing
- No warnings in CI

## Error Handling

- Don't swallow exceptions silently
- Return meaningful messages to clients — see [05-api.md](05-api.md)
- Log details server-side; never expose stack traces to clients
- Never log secrets, tokens, or PII
