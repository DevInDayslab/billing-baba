# Auto-update test report

Generated: 2026-10-17 (local run on Windows).

## Phase 1 — Code map (10 lines)

1. **Debug HTTP manifest:** `AppConfig.updateManifestAllowInsecureHttp` (`UPDATE_MANIFEST_ALLOW_HTTP` in `.env` or `--dart-define=UPDATE_MANIFEST_ALLOW_HTTP=true`, debug-only semantics per `app_config.dart`).
2. **Manifest URL:** `AppConfig.updateManifestUrl` / `updateManifestConfigured` from `UPDATE_MANIFEST_URL`.
3. **`UpdateService`:** `checkForUpdate`, `isForced`, `downloadInstaller`, `verifyChecksum`, `verifySignature`, `launchInstaller`, `currentBuildNumber`.
4. **`UpdateSafetyGate.evaluate()`** → `UpdateSafetyResult` (`hardBlocks`, `softBlocks`); provider: `updateSafetyGateProvider`.
5. **Controller:** `updateControllerProvider` / `UpdateController`; states in `UpdateStatus` + `UpdateState`.
6. **Backup:** `AutoUpdateBackupService.createPreUpdateBackup()` via `autoUpdateBackupServiceProvider`.
7. **Shutdown:** `shutdownForUpdate()` exposed as `shutdownForUpdateProvider` (callable `(Ref) async`).
8. **UI:** `UpdateDialog`, `showUpdateDialog()`, `AppUpdateCoordinator`.
9. **Installer launch:** `buildWindowsInstallerLaunchCommand` / `launchUpdateInstaller` in `update_installer_launcher.dart`.
10. **CI:** `.github/scripts/generate-update-manifest.ps1`, `publish-update.ps1` (installer upload then `version.json` last).

---

## Production / CI changes for testability

| File | Change |
|------|--------|
| `apps/client/lib/core/config/app_config.dart` | Test overrides: `updateManifestUrlOverride`, `updateManifestAllowInsecureHttpOverride`, `resetUpdateManifestOverridesForTest`. |
| `apps/client/lib/features/app_update/data/update_service.dart` | Injectable `resolveUpdatesDirectory`, `launchInstallerFn`, `windowsProcessRunner`, optional `packageInfo`. |
| `apps/client/lib/features/app_update/data/update_installer_launcher.dart` | `buildWindowsInstallerLaunchCommand`, `WindowsInstallerProcessRunner`. |
| `apps/client/lib/features/app_update/application/update_shutdown.dart` | `shutdownForUpdateProvider` for injection in tests. |
| `apps/client/lib/features/app_update/application/auto_update_backup_service.dart` | `backupDirectoryOverride`, `exportBackupFn`, `packageInfoOverride`; `pruneOldBackupsInDirectory` `@visibleForTesting`. |
| `apps/client/lib/features/app_update/presentation/update_dialog.dart` | `showUpdateDialog({required bool isForced})` uses `barrierDismissible: !isForced` (matches coordinator). |
| `.github/scripts/publish-update.ps1` | **`-DryRun`** switch (logs upload order; no `aws` calls). |

Other small production fixes after the initial test pass are noted in **Bugs / gaps** (fixed items) below.

---

## Bugs / gaps found

| Location | Issue | Status |
|----------|--------|--------|
| `update_dialog.dart` `showUpdateDialog()` | Was `barrierDismissible: false` always (About / menu path). | **Fixed:** `showUpdateDialog(isForced: …)` + `barrierDismissible: !isForced`; widget tests in `update_dialog_test.dart`. |
| `new-manifest.ps1` (test kit) | Writes `http://` installer URLs for localhost; real app rejects non-HTTPS installers (`UpdateService.isUrlAllowed`). | **Open:** use HTTPS tunnel URL for installer in E2E, or test-only build defines. |

---

## Table 1 — Automated and passed

| Test / script | Proves | Command | Result |
|---------------|--------|---------|--------|
| `app_update_info_test.dart` | Manifest parsing / validation | `cd apps/client && flutter test test/features/app_update/app_update_info_test.dart` | 10 tests passed |
| `update_service_test.dart` | checkForUpdate, checksum, download, isForced, URLs | `flutter test test/features/app_update/update_service_test.dart` | 26 tests passed |
| `update_installer_launcher_test.dart` | PowerShell command + exit codes | `flutter test test/features/app_update/update_installer_launcher_test.dart` | 3 passed |
| `update_safety_gate_test.dart` | POS/sync gate rules | `flutter test test/features/app_update/update_safety_gate_test.dart` | 5 passed |
| `auto_update_backup_service_test.dart` | Naming, prune to 5, failure | `flutter test test/features/app_update/auto_update_backup_service_test.dart` | 3 passed |
| `update_controller_test.dart` | State machine, retry, UAC, backup abort | `flutter test test/features/app_update/update_controller_test.dart` | 4 passed |
| `update_dialog_test.dart` | Dialog + About UI (incl. `showUpdateDialog` optional/forced) | `flutter test test/features/app_update/update_dialog_test.dart` | 10 passed |
| **Full suite** | All of the above | `cd apps/client && flutter test test/features/app_update/` | **58 passed** (2026-10-17) |
| `setup-test-env.ps1` | Creates `C:\update-test` | `powershell -File scripts/update_test/setup-test-env.ps1` | Created directory |
| `setup-test-env.ps1 -WhatIf` | Dry run | `... -WhatIf` | Printed WhatIf message |
| `new-manifest.ps1` | SHA256 + `version.json` | `new-manifest.ps1 -Version 1.0.1 -Build 2 -InstallerFile C:\update-test\dummy.exe` | Wrote manifest |
| `serve.ps1` + curl | Static hosting + no-cache | Background `serve.ps1`; `curl http://127.0.0.1:8080/version.json` | JSON returned |
| `test-ci-manifest.ps1` | CI manifest generator | `powershell -File scripts/update_test/test-ci-manifest.ps1` | `OK` |
| `publish-update.ps1` guard | Missing `UPDATE_S3_BUCKET` fails | Run without secrets | `Require-Env` error |
| `publish-update.ps1 -DryRun` | Installer first, manifest **last** | `-DryRun` with dummy `dist/` | Log order: installer then `version.json` |

---

## Table 2 — Automated but failed or not run

| Item | Reason | What to do |
|------|--------|------------|
| `build-test-installers.ps1` | **NOT RUN** — `ISCC` / Inno Setup not on PATH (Flutter present). | Install Inno Setup 6, add `ISCC.exe` to PATH, run with `-ManifestUrlHttps <tunnel>/version.json`. |
| `run-debug-app.ps1` | **NOT RUN** — long-running interactive `flutter run`. | Run manually when testing local manifest + `UPDATE_MANIFEST_ALLOW_HTTP`. |
| `verify-install.ps1` | **NOT RUN** — requires completed real install to 1.0.1. | After manual E2E update, run `verify-install.ps1 -ExpectedVersion 1.0.1`. |
| Widget: system Back on forced dialog | `handlePopRoute` may return true in tests while `PopScope` keeps dialog visible; About forced test asserts dialog remains. | Optional sanity check on real Windows with forced update. |

---

## Table 3 — Manual only

1. **UAC Yes:** Start update → approve UAC → app exits, installer runs silent, app relaunches. **Expected:** New version running; no data loss (`verify-install.ps1`).
2. **UAC No:** Decline UAC. **Expected:** Error with administrator permission message; app stays open; DB untouched.
3. **Optional dialog UX:** Barrier tap dismisses when not forced (coordinator, About, and Help → Check for updates). **Expected:** Dismisses when optional; stays open when forced.
4. **Forced dialog:** No Later; barrier/Esc/back do not dismiss.
5. **Progress UI:** Download shows % and MB; matches real download speed.
6. **Silent install + relaunch:** Inno `CloseApplications` + `/SILENT` relaunch; POS data in `%LOCALAPPDATA%\BillingBaba`.
7. **SmartScreen:** Unsigned installer warning on first run (document user choice).
8. **Real HTTPS hosting:** Manifest + installer on production/tunnel URL; no `UPDATE_MANIFEST_ALLOW_HTTP`.
9. **POS hard block:** Open tab with line items → update blocked with tab name.
10. **Sync soft block:** Pending sync queue → warning + “Install anyway”.
11. **Held bills only:** Hold bill, empty cart → update not hard-blocked.
12. **Schema migration:** When schema > 32, follow `scripts/update_test/check-sqlite-migration.md`.

---

## Re-run commands

```powershell
# Unit + widget tests
cd apps\client
flutter test test/features/app_update/

# Local manifest kit
powershell -File scripts\update_test\setup-test-env.ps1
powershell -File scripts\update_test\new-manifest.ps1 -Version 1.0.1 -Build 2 -InstallerFile C:\update-test\dummy.exe
powershell -File scripts\update_test\serve.ps1   # separate terminal
curl http://127.0.0.1:8080/version.json

# CI script smoke
powershell -File scripts\update_test\test-ci-manifest.ps1

# Publish dry-run (no upload)
$env:APP_VERSION="9.9.9"
$env:UPDATE_S3_BUCKET="bucket"
$env:UPDATE_S3_ACCESS_KEY_ID="key"
$env:UPDATE_S3_SECRET_ACCESS_KEY="secret"
powershell -File .github\scripts\publish-update.ps1 -DistDir <path-to-dist> -DryRun
```

---

## Artifacts added

- `apps/client/test/features/app_update/*` (unit + widget tests)
- `scripts/update_test/*` (PowerShell kit + migration note)
- This report
