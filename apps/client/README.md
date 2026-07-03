# Billing Baba — Flutter Client

Offline-first POS, billing, inventory, and business management for Indian retailers.

## Architecture

Billing Baba is **offline-first**: SQLite (Drift) is the primary store on every device. Writes are local first; background sync reconciles with the Fastify API and NeonDB PostgreSQL backend.

```
Presentation (pages/widgets)
        ↓
    Providers
        ↓
Repositories ←→ Services
        ↓
 Drift SQLite / REST API
```

### `core/` — App infrastructure

Cross-cutting code used by every feature. Not business logic.

| Folder | Responsibility |
|--------|----------------|
| `config/` | Environment config (API URL, app name, feature flags) |
| `constants/` | Fixed values that never change per environment |
| `database/` | Drift setup, table definitions, type converters |
| `network/` | Dio client, endpoints, interceptors |
| `router/` | Single global GoRouter — all routes registered here |
| `services/` | App-wide services (storage, connectivity) |
| `theme/` | Colors, typography, spacing, `ThemeData` |
| `utils/` | Helpers (logging, debouncing, validators) |
| `widgets/` | Reusable UI components |

### `shared/` — Cross-feature reuse

Only code that is truly global and not tied to one feature.

| Folder | Responsibility |
|--------|----------------|
| `enums/` | Enums shared across multiple features |
| `widgets/` | Widgets shared across multiple features |

Feature-specific models belong inside their feature, not here.

### `features/` — Business domains

Each feature is self-contained:

```
features/<feature>/
├── presentation/
│   ├── pages/
│   └── widgets/
├── providers/
├── repositories/
├── services/
└── models/
```

**Data flow:** Page → Provider → Repository/Service → Drift or API

**Rules:**
- No business logic in widgets
- No feature-level route files — register routes in `core/router/app_router.dart`
- Keep layers flat — no `domain/`, `data/`, `use_cases/`, etc.

## Tech Stack

| Category | Package |
|----------|---------|
| State | `flutter_riverpod`, `riverpod_annotation` |
| Routing | `go_router` |
| Networking | `dio`, `pretty_dio_logger` |
| Database | `drift`, `drift_flutter`, `sqlite3_flutter_libs` |
| Models | `freezed_annotation`, `json_annotation` |
| Dev | `build_runner`, `riverpod_generator`, `freezed`, `json_serializable`, `drift_dev`, `very_good_analysis` |

## Folder Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   ├── constants/
│   ├── database/
│   │   ├── tables/
│   │   └── converters/
│   ├── network/
│   ├── router/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── shared/
│   ├── enums/
│   └── widgets/
└── features/
    ├── auth/
    ├── dashboard/
    ├── parties/
    ├── inventory/
    ├── sales/
    ├── purchases/
    ├── accounting/
    ├── reports/
    └── settings/
```

## How to Run

```bash
cd apps/client
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Set the API base URL at build time:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

Copy environment variables for MSG91 and optional dev login:

```bash
cp .env.example .env
```

| Variable | Description |
|----------|-------------|
| `MSG91_WIDGET_ID` | MSG91 widget ID for OTP |
| `MSG91_WIDGET_AUTH_TOKEN` | MSG91 widget auth token |
| `ENABLE_DEV_LOGIN` | `true` to show the Developer Login button; **must be `false` in production** |

## Development Login

When `ENABLE_DEV_LOGIN=true` in `apps/client/.env` **and** the API has the same flag enabled, the login screen shows a secondary **Developer Login** button (outlined, not the primary CTA).

Tapping it calls `POST /api/v1/auth/dev-login` through the existing `AuthRepository` → `AuthService` → Riverpod session flow. Navigation after success is identical to a normal OTP login (dashboard, business selection, or create-business placeholder).

When `ENABLE_DEV_LOGIN=false`, the button is hidden and the dev-login route is unavailable on the API. Normal OTP login is unchanged.

**Never enable this in production builds.**

## Code Generation

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch --delete-conflicting-outputs
```

After adding Drift tables under `core/database/tables/`, import them in `database.dart` and re-run build_runner.

## Linting

```bash
flutter analyze
dart format .
```

## Related Documentation

- [Architecture](../../docs/01-architecture.md)
- [Design System](../../docs/03-design-system.md)
- [Coding Standards](../../docs/06-coding-standards.md)
