# Windows auto-update — Railway

Desktop artifacts live under `updates/windows/` on **S3-compatible storage** with **anonymous HTTPS GET**. CI uploads via [`.github/scripts/publish-update.ps1`](../../.github/scripts/publish-update.ps1) (`aws s3 cp` + GitHub `UPDATE_S3_*` secrets).

### Recommended production layout

| Store | Use |
|-------|-----|
| **API private bucket** | User media, backups — stays private |
| **Railway `public files`** (or R2/S3 public prefix) | `updates/windows/version.json` + installers only |
| **`s3-public-presigner`** (optional) | Stable `PUBLIC_BASE` URL in front of the public bucket |

GitHub `UPDATE_S3_*` should use credentials for the **public update bucket**, not the API bucket, unless you have confirmed anonymous read on `updates/windows/*` there.

**Cutover from a private API bucket:** follow [auto-update-public-bucket-cutover.md](auto-update-public-bucket-cutover.md) step by step.

## URL layout

| Item | Value |
|------|--------|
| Object prefix | `updates/windows/` |
| Manifest key | `updates/windows/version.json` |
| Installer key | `updates/windows/BillingBabaSetup-vX.Y.Z.exe` |

Public URLs:

```text
{PUBLIC_BASE}/updates/windows/version.json
{PUBLIC_BASE}/updates/windows/BillingBabaSetup-vX.Y.Z.exe
```

`PUBLIC_BASE` = HTTPS base with **no** trailing slash — typically the public bucket URL or your **presigner** domain. It must match `UPDATE_MANIFEST_URL` / `UPDATE_DOWNLOAD_BASE_URL` in GitHub (not necessarily API `S3_PUBLIC_BASE_URL` unless media and updates share the same public host).

The desktop app requires **HTTPS**, **anonymous GET** on manifest + installer, and **manifest host == installer host**.

## One-time: Railway (your dashboard)

1. Create or open Railway **public files** (separate from the API volume).
2. Note bucket **endpoint**, **bucket name**, and **access keys** for that volume.
3. Choose **`PUBLIC_BASE`**: direct public bucket HTTPS base **or** the **`s3-public-presigner`** service URL (if presigner serves `/updates/windows/...`).
4. Run a smoke test before GitHub cutover — see [auto-update-public-bucket-cutover.md](auto-update-public-bucket-cutover.md) Phase 1.

API service `S3_*` vars remain for app storage; update **`S3_PUBLIC_BASE_URL`** on the API only if public media URLs should use the same host as updates ([storage.md](../04-backend/storage.md)).

Private presigned URLs must **not** appear inside `version.json` (they expire). Stable paths on `PUBLIC_BASE` are required.

### Smoke test (local)

Public bucket (recommended):

```powershell
.\scripts\deployment\smoke-public-update-bucket.ps1 `
  -PublicBaseUrl "https://YOUR_PUBLIC_BASE" `
  -Endpoint "https://YOUR_ENDPOINT" `
  -Bucket "YOUR_BUCKET" `
  -AccessKeyId "..." `
  -SecretAccessKey "..."
```

Or, if `PUBLIC_BASE` equals API `S3_PUBLIC_BASE_URL` and the bucket is public:

```powershell
.\scripts\deployment\verify-update-hosting.ps1 -UploadSmokeTest
```

Or only check an existing manifest URL:

```powershell
.\scripts\deployment\verify-update-hosting.ps1 -ManifestUrl "https://YOUR_PUBLIC_BASE/updates/windows/version.json"
```

Print GitHub variable lines from current env:

```powershell
$env:S3_PUBLIC_BASE_URL = "https://..."   # from Railway
$env:S3_ENDPOINT = "..."
$env:S3_BUCKET = "..."
.\scripts\deployment\print-github-update-config.ps1
```

## One-time: GitHub Actions

**Variables** (repo → Settings → Secrets and variables → Actions → Variables):

| Name | Value |
|------|--------|
| `UPDATE_MANIFEST_URL` | `{PUBLIC_BASE}/updates/windows/version.json` |
| `UPDATE_DOWNLOAD_BASE_URL` | `{PUBLIC_BASE}/updates/windows` |
| `UPDATE_S3_PATH_PREFIX` | `updates/windows` |

**Secrets**:

| Name | Copy from Railway **public update** bucket |
|------|------------------------------------------|
| `UPDATE_S3_BUCKET` | public files bucket name |
| `UPDATE_S3_ACCESS_KEY_ID` | that bucket’s access key |
| `UPDATE_S3_SECRET_ACCESS_KEY` | that bucket’s secret |
| `UPDATE_S3_ENDPOINT` | that bucket’s S3 endpoint |
| `WEBSITE_DEPLOY_HOOK_URL` | Vercel deploy hook (optional) |

See [github-update-config.template.md](github-update-config.template.md) for a checklist.

## One-time: Vercel (`apps/website`)

| Name | Value |
|------|--------|
| `WEBSITE_UPDATE_MANIFEST_URL` | Same as `UPDATE_MANIFEST_URL` |

Redeploy production after setting the variable. Add deploy hook URL to GitHub as `WEBSITE_DEPLOY_HOOK_URL`.

## Ship a release

### Automated (develop / main)

When **`apps/client/pubspec.yaml`** changes on **`develop`** or **`main`**:

1. Workflow [`.github/workflows/desktop-auto-tag.yml`](../../.github/workflows/desktop-auto-tag.yml) creates or **moves** tag **`vX.Y.Z`** (semver from pubspec, before `+`) to that commit.
2. Tag push runs **Build Demo**: build installer, publish to Railway, update `version.json`, GitHub Release, optional Vercel hook.

**You:** bump `version: X.Y.Z+N` (increment **N** every release), optional `docs/release-notes/X.Y.Z.md`, merge to `develop` (or `main`). No manual `git tag` unless you prefer it.

**Same semver, new build** (e.g. `1.0.0+1` → `1.0.0+2`): tag stays `v1.0.0` (force-updated); manifest `latest_build` comes from `+N` in pubspec.

### Manual (optional)

`git tag vX.Y.Z` && `git push origin vX.Y.Z` still works.

### Verify

Watch **Build Demo** on the tag; confirm **Publish update to public hosting** succeeds. Check manifest URL and `https://billingbaba.com/download`.

`UPDATE_MANIFEST_URL` is baked on **tag**, **demo**, **develop**, and **main** builds when the GitHub variable is set. Manifest publish runs on those branch pushes (not only tags) when `UPDATE_DOWNLOAD_BASE_URL` and `UPDATE_MANIFEST_URL` are configured.

## Rollback

Re-upload a previous `version.json` (matching older installer `sha256`) **last**; redeploy the website.

## See also

- [auto-update.md](auto-update.md) — manifest fields, force update, data safety
- [windows-release.md](windows-release.md) — installer CI pipeline
