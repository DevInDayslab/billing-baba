# Website + update hosting integration report

Date: 2026-10-17

## Phase 1 — `apps/website` investigation (read-only)

| # | Finding |
|---|---------|
| 1 | **Stack:** React 19 + Vite 6 + TypeScript 5.8 + React Router 7 + Tailwind CSS v4 + Sass (marketing). **Not Next.js.** Client-side router (`src/router/routes.tsx`). **Package manager:** Bun (`bun.lock`, `vercel.json` `buildCommand: bun run build`). **Build:** `tsc -b && vite build` → static SPA in `dist/`. |
| 2 | **Deploy:** `apps/website/vercel.json` — Vercel, SPA rewrites to `index.html`. `README.md`: production **https://billingbaba.com**. No `netlify.toml`, Dockerfile, or website-specific GitHub workflow found (**NOT FOUND** for non-Vercel deploy automation). |
| 3 | **Env:** `VITE_API_BASE_URL` via `import.meta.env` (`src/api/client.ts`). No `NEXT_PUBLIC_*`. Download CTAs: `/download` route, `DOWNLOAD_URL` in `src/services/deep-link.ts`, nav/footer/landing links. |
| 4 | **Design:** Marketing layout (`MarketingLayout`), `MarketingNav` / `MarketingFooter`, SCSS (`src/styles/marketing/*.scss`), section classes (`four`, `btn`, yellow accent `#ffe500`). No i18n. |
| 5 | **SSR:** **Purely static** (Vite SPA). No server-side request at request time on Vercel unless serverless is added later. |

**Recommendation: Option A** — `updates.billingbaba.com` (or similar) on S3-compatible storage + CDN; main site stays on Vercel. Option B (SFTP to same VPS) **not implemented** (not applicable).

---

## Hosting option implemented

**Option A (S3-compatible)** — extended `publish-update.ps1` / `generate-update-manifest.ps1`; documented DNS and same-host rule in `docs/deployment/auto-update.md`.

---

## Files created / changed

### Website (`apps/website`)

| Path | Change |
|------|--------|
| `src/lib/windows-release.ts` | Manifest parse/validate/fetch (`getLatestWindowsRelease`) |
| `src/lib/windows-release-snapshot.ts` | Build snapshot loader |
| `src/lib/windows-release.test.ts` | Vitest unit tests |
| `src/generated/windows-release.snapshot.json` | Embedded release data (prebuild) |
| `scripts/fetch-windows-release.ts` | Prebuild fetch |
| `src/components/marketing/DownloadButton.tsx` | Download UI + verify + SmartScreen note |
| `src/pages/marketing/DownloadPage.tsx` | `/download` page + meta title |
| `src/constants/smartscreen.ts` | SmartScreen copy constant |
| `src/pages/marketing/LandingPage.tsx` | Compact `DownloadButton` in CTA section |
| `public/sitemap.xml` | Includes `/download` |
| `.env.example` | `WEBSITE_UPDATE_MANIFEST_URL` |
| `package.json` | `prebuild`, `test`, vitest |
| `vitest.config.ts` | Test runner |
| `README.md` | Env docs |

### CI / docs

| Path | Change |
|------|--------|
| `.github/scripts/publish-update.ps1` | Host guard, retention (5 + current), DryRun prune message |
| `.github/scripts/generate-update-manifest.ps1` | Host guard vs `UPDATE_MANIFEST_URL` |
| `.github/workflows/build-demo.yml` | Tag-only `UPDATE_MANIFEST_URL` bake; publish env; website deploy hook step |
| `docs/deployment/auto-update.md` | Option A DNS, website env, rollback, SmartScreen removal |

---

## Command outputs (this session)

### Website tests

```
bun run test
✓ src/lib/windows-release.test.ts (9 tests)
```

### Website typecheck + build

```
bun run typecheck  → exit 0
bun run build      → vite build ✓ (prebuild: snapshot unavailable without WEBSITE_UPDATE_MANIFEST_URL)
```

### Publish `-DryRun`

```
[DryRun] Would upload installer to s3://b/updates/windows/BillingBabaSetup-v9.9.9.exe
[DryRun] Would upload manifest LAST to s3://b/updates/windows/version.json
[DryRun] Would prune installers under s3://b/updates/windows/ (keep 5 newest + BillingBabaSetup-v9.9.9.exe)
DryRun complete (no uploads performed).
```

### Host mismatch guard

```
generate-update-manifest.ps1 → UPDATE_MANIFEST_URL host (a.example.com) must match UPDATE_DOWNLOAD_BASE_URL host (b.example.com)
```

---

## Assumptions / limitations

1. **Static site:** Release info is baked at **Vercel build** via `WEBSITE_UPDATE_MANIFEST_URL`. After each desktop tag release, run **Vercel deploy hook** (`WEBSITE_DEPLOY_HOOK_URL`) or manual redeploy unless client-side refresh succeeds (requires **CORS** on the update bucket for `https://billingbaba.com`).
2. **Installer file size** is not in `version.json`; UI omits size (per spec).
3. **Option B / SFTP** not implemented.
4. **`release.yml`** not touched.

---

## Manual checklist

1. Create R2/S3 bucket; public read on `updates/windows/*`.
2. DNS: `updates.billingbaba.com` → CDN/bucket (HTTPS).
3. GitHub vars: `UPDATE_MANIFEST_URL`, `UPDATE_DOWNLOAD_BASE_URL` (same host), `UPDATE_S3_PATH_PREFIX`.
4. GitHub secrets: `UPDATE_S3_*`, optional `WEBSITE_DEPLOY_HOOK_URL` (Vercel → Project → Settings → Deploy Hooks).
5. Vercel project env: `WEBSITE_UPDATE_MANIFEST_URL` = same URL as `UPDATE_MANIFEST_URL`.
6. Bucket CORS: allow `GET` from `https://billingbaba.com` (optional live refresh).
7. Push tag `vX.Y.Z`; verify installer + `version.json` on update host, then `/download` on billingbaba.com after hook/build.
8. Rollback: re-upload previous `version.json` last; redeploy website.

---

## Re-run commands

```powershell
cd apps\website
bun install
bun run test
bun run typecheck
$env:WEBSITE_UPDATE_MANIFEST_URL="https://updates.billingbaba.com/windows/version.json"
bun run build

cd ..\..
powershell -File scripts\update_test\test-ci-manifest.ps1
```
