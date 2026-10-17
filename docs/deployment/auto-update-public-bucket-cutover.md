# Desktop auto-update — public bucket cutover (Railway)

Use this when the **API’s private Railway bucket** returns `AccessDenied` for anonymous `GET` on `version.json`. Desktop updates must live in a **separate public bucket** (Railway **public files**) or behind **`s3-public-presigner`**, not in the same private store as user media.

CI and the Flutter app are already built for this model: GitHub `UPDATE_S3_*` points at the upload target; `UPDATE_MANIFEST_URL` / `UPDATE_DOWNLOAD_BASE_URL` define stable **HTTPS** URLs (same host).

## What you need before starting

| Item | Where to get it |
|------|------------------|
| Public bucket name | Railway → **public files** |
| S3 endpoint, access key, secret | Railway → **public files** → credentials (not API service vars) |
| `PUBLIC_BASE` | Public HTTPS base for objects (bucket public URL **or** presigner domain, **no** trailing slash) |
| Presigner path map | Whoever deployed **s3-public-presigner** (if URLs go through presigner) |

**Do not** use API `S3_*` for `UPDATE_S3_*` unless that bucket is genuinely public for `updates/windows/*` (usually it is not).

## Phase 1 — Smoke test (required)

Prove anonymous read before changing GitHub or shipping builds.

### Option A — Repo script (recommended)

From repo root in PowerShell (install [AWS CLI](https://aws.amazon.com/cli/) if needed):

```powershell
.\scripts\deployment\smoke-public-update-bucket.ps1 `
  -PublicBaseUrl "https://YOUR_PUBLIC_BASE" `
  -Endpoint "https://YOUR_ENDPOINT" `
  -Bucket "YOUR_BUCKET" `
  -AccessKeyId "YOUR_KEY" `
  -SecretAccessKey "YOUR_SECRET"
```

Success: `[OK] Anonymous GET works` for `.../updates/windows/smoke-test.json`.

Delete the smoke object in Railway UI or:

```powershell
aws s3 rm "s3://YOUR_BUCKET/updates/windows/smoke-test.json" --endpoint-url "https://YOUR_ENDPOINT"
```

### Option B — Railway UI

1. Open **public files** → upload a small file to `updates/windows/smoke-test.json`.
2. In an incognito browser, open `https://YOUR_PUBLIC_BASE/updates/windows/smoke-test.json`.
3. Expect **200** and file contents — not XML `AccessDenied`.

If this fails, fix Railway public access or presigner routing before continuing.

## Phase 2 — GitHub Actions

Repo → **Settings** → **Secrets and variables** → **Actions**.

### Variables

| Name | Value |
|------|--------|
| `UPDATE_MANIFEST_URL` | `https://YOUR_PUBLIC_BASE/updates/windows/version.json` |
| `UPDATE_DOWNLOAD_BASE_URL` | `https://YOUR_PUBLIC_BASE/updates/windows` |
| `UPDATE_S3_PATH_PREFIX` | `updates/windows` |

**Rule:** `UPDATE_MANIFEST_URL` and `UPDATE_DOWNLOAD_BASE_URL` must have the **same hostname**.

### Secrets (public bucket only)

| Name | Value |
|------|--------|
| `UPDATE_S3_BUCKET` | public files bucket name |
| `UPDATE_S3_ACCESS_KEY_ID` | public bucket access key |
| `UPDATE_S3_SECRET_ACCESS_KEY` | public bucket secret |
| `UPDATE_S3_ENDPOINT` | public bucket S3 endpoint |
| `WEBSITE_DEPLOY_HOOK_URL` | unchanged (Vercel deploy hook, optional) |

Helper after exporting values in PowerShell:

```powershell
$env:S3_PUBLIC_BASE_URL = "https://YOUR_PUBLIC_BASE"
$env:S3_BUCKET = "YOUR_BUCKET"
$env:S3_ENDPOINT = "https://YOUR_ENDPOINT"
.\scripts\deployment\print-github-update-config.ps1
```

## Phase 3 — Publish installer + manifest

Artifacts must exist at:

- `updates/windows/BillingBabaSetup-vX.Y.Z.exe`
- `updates/windows/version.json` (uploaded **last**)

### Option A — Re-run CI

1. Open **Actions** → **Build Demo**.
2. Run on `develop` / `main` / `demo`, or re-push tag `v1.0.2`, or use **workflow_dispatch** if available.
3. Confirm step **Publish update to public hosting** succeeds.

### Option B — Manual (if you have `dist/` from a previous build)

```powershell
$env:APP_VERSION = "1.0.2"
$env:UPDATE_MANIFEST_URL = "https://YOUR_PUBLIC_BASE/updates/windows/version.json"
$env:UPDATE_DOWNLOAD_BASE_URL = "https://YOUR_PUBLIC_BASE/updates/windows"
$env:UPDATE_S3_BUCKET = "..."
$env:UPDATE_S3_ACCESS_KEY_ID = "..."
$env:UPDATE_S3_SECRET_ACCESS_KEY = "..."
$env:UPDATE_S3_ENDPOINT = "..."
$env:UPDATE_S3_PATH_PREFIX = "updates/windows"

.\.github\scripts\generate-update-manifest.ps1 -DistDir "dist"
.\.github\scripts\publish-update.ps1 -DistDir "dist"
```

## Phase 4 — Verify production URLs

```powershell
.\scripts\deployment\verify-update-hosting.ps1 `
  -ManifestUrl "https://YOUR_PUBLIC_BASE/updates/windows/version.json"
```

Checklist:

- [ ] Manifest JSON opens in browser (no login).
- [ ] `latest_version` / `latest_build` match what you shipped.
- [ ] `installer_url` host equals manifest URL host.
- [ ] Opening `installer_url` downloads the `.exe`.

## Phase 5 — Website (Vercel)

Project env (production):

| Name | Value |
|------|--------|
| `WEBSITE_UPDATE_MANIFEST_URL` | same as `UPDATE_MANIFEST_URL` |

Redeploy production (deploy hook or manual). Confirm https://billingbaba.com/download shows the new version.

## Phase 6 — Desktop clients

### New installs / new CI builds

The next **Build Demo** run bakes:

`--dart-define=UPDATE_MANIFEST_URL=...`

into the Windows `.exe`. Those builds will use the public manifest.

### Users already on v1.0.1 (important)

`UPDATE_MANIFEST_URL` is **compiled into** the app at build time. Changing GitHub variables does **not** change apps already installed.

| Scenario | Action |
|----------|--------|
| Old manifest URL can never be made public | Users need **one manual download** from the website; after that, in-app updates work. |
| You ship v1.0.3 with new URL | Communicate one-time manual update for 1.0.1 users. |

Plan support messaging with your team before cutover.

## Phase 7 — End-to-end test

1. Install a build that includes the **new** `UPDATE_MANIFEST_URL` (fresh CI build or local with `--dart-define`).
2. Use an app version **older** than manifest (e.g. app 1.0.1, manifest 1.0.2).
3. **Check for updates** → should offer the new version.
4. Download and install; confirm checksum step succeeds.

## Rollback

1. Re-upload the previous `BillingBabaSetup-*.exe` if removed.
2. Re-upload the previous `version.json` **last** (same `sha256` as that installer).
3. Redeploy website if download page version changed.

## Troubleshooting

| Symptom | Likely fix |
|---------|------------|
| `AccessDenied` on manifest | Wrong bucket in `UPDATE_S3_*`; or `PUBLIC_BASE` does not match where objects are served |
| “You’re up to date” with newer manifest live | Installed app has old/broken manifest URL or same version as manifest; check app logs for `[UPDATE] checkForUpdate failed` |
| CI publish fails | Wrong endpoint; try path-style (default). Set GitHub variable `UPDATE_S3_FORCE_PATH_STYLE` to `false` only if your provider requires virtual-hosted style |
| Host mismatch in CI | Align `UPDATE_MANIFEST_URL` and `UPDATE_DOWNLOAD_BASE_URL` hosts |
| Manifest OK, download fails | Installer missing in bucket or not reachable on same host as manifest |

## See also

- [auto-update-railway.md](auto-update-railway.md) — URL layout and routine releases
- [auto-update.md](auto-update.md) — manifest fields, force update, local testing
- [github-update-config.template.md](github-update-config.template.md) — variable checklist
