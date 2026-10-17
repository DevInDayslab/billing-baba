# Windows desktop auto-update

Billing Baba desktop (Windows) checks a **public** `version.json` manifest hosted on your infrastructure. The app never downloads updates from GitHub (the repository is private).

## Shipping a release

1. Bump **both** semver and build number in [`apps/client/pubspec.yaml`](../../apps/client/pubspec.yaml):
   ```yaml
   version: 1.1.0+2
   ```
   The updater compares **build numbers** (`+2`). Every release must increment the build.
2. Commit and push tag `v1.1.0` (semver only in tag name).
3. The [`build-demo`](../../.github/workflows/build-demo.yml) workflow on `v*` tags:
   - Builds `dist/BillingBabaSetup-v1.1.0.exe`
   - Writes `dist/version.json` (when `UPDATE_DOWNLOAD_BASE_URL` is set)
   - Publishes **installer first**, then **`version.json` last** (`publish-update.ps1`)
   - Optionally POSTs `WEBSITE_DEPLOY_HOOK_URL` (non-fatal if it fails)
   - **Prunes** old installers last (`publish-update.ps1 -PruneOnly`; semver-based retention, non-fatal on error)
   - Uploads all `dist/*` assets to the GitHub Release as an internal backup

**Tag-only updater URL:** `UPDATE_MANIFEST_URL` is baked into the desktop app **only** on `v*` tag builds. `develop` / `demo` branch builds do not receive production manifest URLs.

Clients read only the public manifest URL configured as `UPDATE_MANIFEST_URL` on release builds.

## Force update

Manifest fields:

| Field | Effect |
|-------|--------|
| `force_update: true` | User cannot dismiss the update dialog (`Later` hidden, barrier not dismissible). |
| `min_supported_build` | If the installed build is **less than** this value, the update is treated as forced. |

Forced updates still **block** when a POS tab has items or payments in progress. They never destroy an in-progress sale.

Workflow dispatch inputs `force_update` and `min_supported_build` apply when generating `version.json` on manual workflow runs.

## Hosting setup (one-time) — Option A (recommended)

The marketing site (`apps/website`) is a **static Vite SPA on Vercel** at `https://billingbaba.com`. Windows installers and `version.json` live on a **separate update host** (subdomain + object storage), not on the main website origin.

1. Create an S3-compatible bucket (AWS S3, Cloudflare R2, etc.).
2. Enable **public read** only for the update prefix (e.g. `updates/windows/*`), not the whole bucket.
3. Attach a custom domain, e.g. **`updates.billingbaba.com`**, to the bucket or CDN (HTTPS required).
4. DNS: add a CNAME (or provider-specific record) from `updates.billingbaba.com` → bucket/CDN endpoint.
5. Set GitHub **variables** and **secrets** (see below).
6. **`UPDATE_MANIFEST_URL` and `UPDATE_DOWNLOAD_BASE_URL` must use the same hostname** (desktop updater enforces installer host == manifest host). Example:
   - `UPDATE_MANIFEST_URL` = `https://updates.billingbaba.com/windows/version.json`
   - `UPDATE_DOWNLOAD_BASE_URL` = `https://updates.billingbaba.com/windows`
7. Configure **CORS** on the bucket for `GET` from `https://billingbaba.com` if you want the download page to refresh the manifest in the browser; the **build-time snapshot** remains the primary source of truth on Vercel.

CI fails if manifest and download-base hosts differ (`generate-update-manifest.ps1`, `publish-update.ps1`).

**Object storage token:** use credentials scoped to the update bucket/prefix only, with **Object Read & Write** (list, upload, and **delete** for pruning). If delete/list is denied, **releases still succeed**; the prune step logs `::warning::Prune skipped: …` and exits successfully. Upload failures (installer or manifest) still fail the workflow.

### Credential rotation

1. Create new object-storage access keys with the same prefix policy.
2. Update GitHub secrets `UPDATE_S3_ACCESS_KEY_ID` and `UPDATE_S3_SECRET_ACCESS_KEY`.
3. Run a test tag build or upload manually; revoke old keys.

## Code signing (later)

1. Obtain a Windows Authenticode certificate.
2. Uncomment / configure `SignTool=` in [`installer/BillingBaba.iss`](../../installer/BillingBaba.iss).
3. Implement Authenticode verification in `UpdateService.verifySignature` (currently a no-op placeholder).

## Local testing

1. Serve a test manifest and installer over HTTP **only in debug**:
   - `UPDATE_MANIFEST_ALLOW_HTTP=true` in `.env` or `--dart-define=UPDATE_MANIFEST_ALLOW_HTTP=true`
   - `UPDATE_MANIFEST_URL=http://127.0.0.1:8080/version.json`
2. Lower the build number in `pubspec.yaml` temporarily so the manifest appears newer.
3. Exercise: optional vs forced update, UAC decline, checksum mismatch (wrong `sha256`), blocked update with items in a POS tab, soft block with pending sync + “Install anyway”.

## Data safety

- SQLite lives at `%LOCALAPPDATA%\BillingBaba\databases\` (outside `{app}`).
- Pre-update backups: `%LOCALAPPDATA%\BillingBaba\auto_backups\` (last 5 `.biba` files).
- Inno `[UninstallDelete]` removes only `{app}` under Program Files — not user databases or backups.

## GitHub configuration

### Repository variables

| Variable | Example |
|----------|---------|
| `UPDATE_MANIFEST_URL` | `https://updates.billingbaba.com/windows/version.json` |
| `UPDATE_DOWNLOAD_BASE_URL` | `https://updates.billingbaba.com/windows` |
| `UPDATE_S3_PATH_PREFIX` | `updates/windows` |

### Repository secrets (publish step only)

| Secret | Example |
|--------|---------|
| `UPDATE_S3_BUCKET` | `billing-baba-updates` |
| `UPDATE_S3_ACCESS_KEY_ID` | `AKIAxxxxxxxx` |
| `UPDATE_S3_SECRET_ACCESS_KEY` | `(secret)` |
| `UPDATE_S3_ENDPOINT` | `https://xxxx.r2.cloudflarestorage.com` (optional) |

### Website (Vercel) — `apps/website`

| Setting | Example | Notes |
|---------|---------|--------|
| `WEBSITE_UPDATE_MANIFEST_URL` | `https://updates.billingbaba.com/windows/version.json` | **Build-time** env in Vercel (not `VITE_`). Same URL as `UPDATE_MANIFEST_URL`. |

Optional secret:

| Secret | Purpose |
|--------|---------|
| `WEBSITE_DEPLOY_HOOK_URL` | Vercel deploy hook; called after a successful tag publish so `/download` picks up the new manifest. Skipped when empty. |

Public download page: `https://billingbaba.com/download` (reads build snapshot + optional client refresh).

## Rollback

1. Keep the previous `BillingBabaSetup-vX.Y.Z.exe` in object storage (retention keeps the last five installers plus the current release).
2. Re-upload a **previous** `version.json` that points at the older installer URL and matching `sha256` (upload manifest **last**).
3. Trigger a website redeploy (deploy hook or manual Vercel redeploy) so `/download` matches.

## Remove SmartScreen notice (after code signing)

1. Sign installers in Inno (`SignTool` in `BillingBaba.iss`).
2. Implement `UpdateService.verifySignature` on desktop.
3. Delete `WINDOWS_SMARTSCREEN_NOTICE` in `apps/website/src/constants/smartscreen.ts` and remove its use in `DownloadButton`.

See also: [Windows release pipeline](windows-release.md).
