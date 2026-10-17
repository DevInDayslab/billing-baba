# GitHub + Vercel update config checklist (Railway public update bucket)

Copy upload credentials from Railway **public files** (or your dedicated update bucket). Use **`PUBLIC_BASE`** for URLs (bucket public host or `s3-public-presigner`). Do not commit real secrets to git.

Full cutover: [auto-update-public-bucket-cutover.md](auto-update-public-bucket-cutover.md).

## Derive `PUBLIC_BASE`

```text
PUBLIC_BASE = S3_PUBLIC_BASE_URL (no trailing slash)
```

## GitHub Actions — Variables

| Name | Your value |
|------|------------|
| `UPDATE_MANIFEST_URL` | `PUBLIC_BASE`/updates/windows/version.json |
| `UPDATE_DOWNLOAD_BASE_URL` | `PUBLIC_BASE`/updates/windows |
| `UPDATE_S3_PATH_PREFIX` | `updates/windows` |

## GitHub Actions — Secrets

| Name | Railway source |
|------|----------------|
| `UPDATE_S3_BUCKET` | `S3_BUCKET` |
| `UPDATE_S3_ACCESS_KEY_ID` | `S3_ACCESS_KEY_ID` |
| `UPDATE_S3_SECRET_ACCESS_KEY` | `S3_SECRET_ACCESS_KEY` |
| `UPDATE_S3_ENDPOINT` | `S3_ENDPOINT` |
| `WEBSITE_DEPLOY_HOOK_URL` | Vercel → Settings → Deploy Hooks |

## Vercel — Production env

| Name | Value |
|------|--------|
| `WEBSITE_UPDATE_MANIFEST_URL` | Same as `UPDATE_MANIFEST_URL` |

## After first tag

- [ ] `PUBLIC_BASE/updates/windows/version.json` returns JSON in browser
- [ ] `installer_url` from JSON downloads the `.exe`
- [ ] GitHub Release contains `dist/*`
- [ ] `/download` shows the new version (after hook or manual redeploy)
