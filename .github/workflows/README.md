# GitHub Actions Workflows

CI/CD for Billing Baba. See [07-git-workflow.md](../../docs/07-git-workflow.md) for branch strategy.

## Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| [backend-ci.yml](./backend-ci.yml) | PR / push → `develop` | API typecheck, lint, build, and tests |
| [flutter-ci.yml](./flutter-ci.yml) | PR / push → `develop` | Dart format, analyze, and unit/widget tests |
| [release.yml](./release.yml) | push → `main` | Desktop + API production artifacts and GitHub Release |
| [build-demo.yml](./build-demo.yml) | push → `demo`, manual | Internal unsigned Windows demo builds |

## Branch strategy

- **develop** — CI runs on every PR and push. No desktop binaries are built.
- **main** — Release workflow only. Bump `version` in `apps/client/pubspec.yaml` before merging.

## Backend tests

Tests live under `apps/api/tests/`:

- `unit/` — utilities, validators, pricing, GST, and service rules (no database)
- `integration/` — one focused CRUD flow per module (PostgreSQL required)
- `smoke/` — fast API validation (boot, health, auth, one CRUD per module)

Run locally:

```bash
cd apps/api
bun test tests/unit          # fast, no DB
bun test tests               # full suite (needs DATABASE_URL + JWT secrets)
```

## Release configuration

Flutter workflows generate `apps/client/.env` at runtime via
[setup-flutter-env.sh](../scripts/setup-flutter-env.sh). Never commit `.env`.

Workflow steps set repository variables/secrets in `env:` and call the script
from the repository root (`working-directory: .`).

Set repository **Variables**:

| Variable | Used by |
|----------|---------|
| `APP_ENV` | Flutter CI, Release |
| `DEBUG` | Flutter CI, Release |
| `ENABLE_DEV_LOGIN` | Flutter CI, Release |
| `DEV_OTP` | Flutter CI, Release |
| `API_BASE_URL` | Flutter CI, Release |

Set repository **Secrets**:

| Secret | Used by |
|--------|---------|
| `MSG91_WIDGET_ID` | Flutter CI, Release |
| `MSG91_WIDGET_AUTH_TOKEN` | Flutter CI, Release |

macOS DMG signing/notarization can replace the ZIP packaging step in `release.yml` when certificates are configured.
