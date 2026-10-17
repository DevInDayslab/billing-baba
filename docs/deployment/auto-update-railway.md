# Windows auto-update — Railway (same bucket as API)

Use **Railway Object Storage** (S3-compatible) with the **same bucket** as the Fastify API. Desktop artifacts live under `updates/windows/`; user media stays under other prefixes.

CI uploads via [`.github/scripts/publish-update.ps1`](../../.github/scripts/publish-update.ps1) (`aws s3 cp` + `UPDATE_S3_*` secrets). No Cloudflare R2 required.

## URL layout

| Item | Value |
|------|--------|
| Object prefix | `updates/windows/` |
| Manifest key | `updates/windows/version.json` |
| Installer key | `updates/windows/BillingBabaSetup-vX.Y.Z.exe` |

Public URLs (must match `S3_PUBLIC_BASE_URL` on the API):

```text
{PUBLIC_BASE}/updates/windows/version.json
{PUBLIC_BASE}/updates/windows/BillingBabaSetup-vX.Y.Z.exe
```

`PUBLIC_BASE` = API env `S3_PUBLIC_BASE_URL` without a trailing slash.

The desktop app requires **HTTPS**, **anonymous GET** on manifest + installer, and **manifest host == installer host**.

## One-time: Railway (your dashboard)

1. Open the **API** service → **Variables**.
2. Confirm storage is configured: `S3_ENDPOINT`, `S3_BUCKET`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`.
3. Set **`S3_PUBLIC_BASE_URL`** if missing (public HTTPS base for object keys — same as used for public media URLs in [storage.md](../04-backend/storage.md)).
4. Ensure objects under `updates/windows/` are **publicly readable** (bucket/policy or Railway public access for that path). Private presigned URLs cannot be used in `version.json`.

### Smoke test (local)

From repo root, after exporting the same `S3_*` values as production:

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

| Name | Copy from Railway API |
|------|------------------------|
| `UPDATE_S3_BUCKET` | `S3_BUCKET` |
| `UPDATE_S3_ACCESS_KEY_ID` | `S3_ACCESS_KEY_ID` |
| `UPDATE_S3_SECRET_ACCESS_KEY` | `S3_SECRET_ACCESS_KEY` |
| `UPDATE_S3_ENDPOINT` | `S3_ENDPOINT` |
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

`UPDATE_MANIFEST_URL` is baked on **tag**, **develop**, and **main** builds (not `demo` branch).

## Rollback

Re-upload a previous `version.json` (matching older installer `sha256`) **last**; redeploy the website.

## See also

- [auto-update.md](auto-update.md) — manifest fields, force update, data safety
- [windows-release.md](windows-release.md) — installer CI pipeline
