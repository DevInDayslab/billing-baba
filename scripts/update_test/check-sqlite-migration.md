# SQLite migration check (update test kit)

For the **1.0.0 → 1.0.1** test installers, the Drift schema version stays **32**. Opening a copied database with the newer build mainly proves the app still starts and reads data; it does **not** exercise a new migration until a release bumps `schemaVersion` in `apps/client/lib/core/database/database.dart`.

## Manual check (recommended)

1. Copy `%LOCALAPPDATA%\BillingBaba\databases\billing_baba.sqlite` to a safe path (never write to the live file).
2. Run the **new** `billing_baba.exe` against that copy (or restore the copy into a temp profile) and confirm login, parties, and inventory load.
3. After a release that increases schema version, repeat and confirm `PRAGMA user_version` matches the expected version.

## Optional automation (future)

When schema changes, add a small integration test under `apps/client/test/integration/` that opens a fixture `.sqlite` with `AppDatabase` and asserts `schemaVersion`.
