# Windows Release Pipeline

Billing Baba ships Windows desktop builds through GitHub Actions. Each run produces an installer, a portable ZIP, checksums, a GitHub Release (when triggered from `demo` or a version tag), and workflow artifacts for internal use.

## What Gets Built

| Output | Description |
|--------|-------------|
| `BillingBabaSetup-v<version>.exe` | Inno Setup installer — recommended for clients |
| `BillingBaba-Windows-v<version>.zip` | Portable build of the Flutter `Release` folder |
| `SHA256SUMS.txt` | SHA256 hashes for the installer and ZIP |

Version `<version>` is read from `apps/client/pubspec.yaml` (the part before `+`, e.g. `1.0.0` from `1.0.0+1`).

## GitHub Workflow

Workflow file: [`.github/workflows/build-demo.yml`](../../.github/workflows/build-demo.yml)

### Triggers

| Trigger | Release behaviour |
|---------|-------------------|
| Push to `demo` branch | Creates/updates prerelease **Demo Build** (`demo-build` tag) |
| Push of tag `v*` (e.g. `v1.0.0`) | Creates GitHub Release with auto-generated release notes |
| Manual `workflow_dispatch` | Builds artifacts; publishes release only when run on `demo` |

### Pipeline stages

1. **Checkout & version** — read `pubspec.yaml`, determine release metadata
2. **Environment** — generate Flutter `.env` via `setup-flutter-env.sh`
3. **Flutter build** — `flutter clean`, `flutter pub get`, `flutter build windows --release`
4. **Verify** — fail if `billing_baba.exe` is missing
5. **VC++ runtime** — download/cache `vc_redist.x64.exe`
6. **Installer** — compile `installer/BillingBaba.iss` with Inno Setup 6
7. **ZIP** — compress the full `Release` folder
8. **Checksums** — write `SHA256SUMS.txt`
9. **GitHub Release** — upload installer, ZIP, and checksums
10. **Artifacts** — upload the same files for workflow downloads

### Fail-fast checks

The workflow exits with an error if any of these are missing after their step:

- `build/windows/x64/runner/Release/billing_baba.exe`
- `dist/BillingBabaSetup-v<version>.exe`
- `apps/client/BillingBaba-Windows-v<version>.zip`

## Inno Setup Installer

Script: [`installer/BillingBaba.iss`](../../installer/BillingBaba.iss)

The installer:

- Installs to `Program Files\Billing Baba`
- Copies the complete Flutter `Release` output (executable, DLLs, `data/`, etc.)
- Creates Start Menu and Desktop shortcuts
- Registers an uninstaller in Windows Settings
- Optionally launches Billing Baba after installation
- Installs the Microsoft Visual C++ 2015–2022 Redistributable (x64) when not already present

### Local compilation

1. Install [Inno Setup 6](https://jrsoftware.org/isinfo.php)
2. Build the Flutter Windows release locally:
   ```bash
   cd apps/client
   flutter build windows --release
   ```
3. Download the VC++ redistributable into `installer/deps/`:
   ```powershell
   mkdir installer\deps -Force
   Invoke-WebRequest https://aka.ms/vs/17/release/vc_redist.x64.exe -OutFile installer\deps\vc_redist.x64.exe
   ```
4. Compile from the repository root:
   ```powershell
   & "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" installer\BillingBaba.iss
   ```

Output is written to `dist/BillingBabaSetup-v<version>.exe`.

## VC++ Runtime

Flutter Windows builds depend on the MSVC runtime (`MSVCP140.dll`, `VCRUNTIME140.dll`, etc.). The installer bundles `vc_redist.x64.exe` and runs it silently (`/install /quiet /norestart`) only when the x64 VC++ 2015–2022 runtime is not already registered.

CI downloads the redistributable from:

`https://aka.ms/vs/17/release/vc_redist.x64.exe`

The file is cached between workflow runs (`installer/deps/vc_redist.x64.exe`).

## Publishing Releases

### Demo builds

Push to the `demo` branch (or run the workflow on `demo`). GitHub Releases will show a prerelease named **Demo Build** at tag `demo-build`. Each push replaces the attached assets with the latest build.

### Versioned releases

1. Bump `version` in `apps/client/pubspec.yaml`
2. Commit and push a matching tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The workflow creates release `Billing Baba 1.0.0` with generated release notes

Clients should download **`BillingBabaSetup-v<version>.exe`** from GitHub Releases.

The portable ZIP remains available for debugging, portable use, and internal testing.

## Bumping Versions

1. Edit `version` in `apps/client/pubspec.yaml`:
   ```yaml
   version: 1.0.1+2
   ```
   Only the semver portion (`1.0.1`) is used for installer and archive filenames.
2. For production releases, merge to the appropriate branch and tag `v1.0.1`.
3. For demo builds, push to `demo` — filenames update automatically from `pubspec.yaml`.

## Future: Code Signing

The installer is currently **unsigned**, which is acceptable for alpha and demo distribution. Windows SmartScreen may warn on first download.

When a code-signing certificate is available, add signing with minimal workflow changes:

1. Store the certificate (`.pfx`) as a GitHub Actions secret
2. Import the certificate in a workflow step before compiling Inno Setup
3. Uncomment the `SignTool` line in `installer/BillingBaba.iss`
4. Sign the installer after compilation if not handled by Inno Setup

Placeholder comments in the workflow and `.iss` file mark where signing hooks belong.

## Future: Auto-Updater and MSIX

Not implemented yet. The current layout keeps the installer and versioned filenames stable so these can be added later:

- **Auto-updater** — e.g. query GitHub Releases API for `v*` tags, compare semver, download new `BillingBabaSetup-v*.exe`
- **MSIX** — separate packaging step after the Flutter build for Microsoft Store distribution
