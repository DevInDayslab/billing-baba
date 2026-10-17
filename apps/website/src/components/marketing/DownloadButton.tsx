import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { WINDOWS_SMARTSCREEN_NOTICE } from '../../constants/smartscreen';
import {
  fetchLatestWindowsRelease,
  type WindowsReleaseResult,
} from '../../lib/windows-release';
import {
  getSnapshotManifestUrl,
  loadWindowsReleaseSnapshot,
} from '../../lib/windows-release-snapshot';

type Props = {
  compact?: boolean;
};

function isWindows(): boolean {
  if (typeof navigator === 'undefined') return true;
  return /Windows/i.test(navigator.userAgent);
}

function formatPublished(date: Date | null): string | null {
  if (!date) return null;
  return date.toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

function installerFileName(url: string): string {
  try {
    const parts = new URL(url).pathname.split('/');
    return parts[parts.length - 1] || 'BillingBabaSetup.exe';
  } catch {
    return 'BillingBabaSetup.exe';
  }
}

export function DownloadButton({ compact = false }: Props) {
  const [result, setResult] = useState<WindowsReleaseResult>(() =>
    loadWindowsReleaseSnapshot(),
  );
  const [verifyOpen, setVerifyOpen] = useState(false);
  const manifestUrl = getSnapshotManifestUrl();

  useEffect(() => {
    if (!manifestUrl) return;
    let cancelled = false;
    void fetchLatestWindowsRelease(manifestUrl).then((next) => {
      if (!cancelled && next.ok) {
        setResult(next);
      }
    });
    return () => {
      cancelled = true;
    };
  }, [manifestUrl]);

  const windows = isWindows();

  if (!result.ok) {
    return (
      <div className="download-panel download-panel--unavailable">
        <p style={{ color: 'white', textAlign: 'center' }}>
          Windows download is coming soon.{' '}
          <Link to="/contact" style={{ color: '#ffe500' }}>Contact us</Link> for
          early access.
        </p>
      </div>
    );
  }

  const { manifest, publishedAt } = result.release;
  const publishedLabel = formatPublished(publishedAt);
  const fileName = installerFileName(manifest.installer_url);

  if (compact) {
    return (
      <a
        className="download-cta-compact"
        href={manifest.installer_url}
        rel="noopener noreferrer"
      >
        <button type="button">
          Download for Windows v{manifest.latest_version}
        </button>
      </a>
    );
  }

  return (
    <div className="download-panel">
      <div className="btn" style={{ flexDirection: 'column', gap: '1rem' }}>
        <a href={manifest.installer_url} rel="noopener noreferrer">
          <button type="button">
            Download for Windows v{manifest.latest_version}
          </button>
        </a>
        {publishedLabel ? (
          <p style={{ color: 'white', margin: 0, fontSize: '0.95rem' }}>
            Released {publishedLabel}
          </p>
        ) : null}
        {!windows ? (
          <p style={{ color: 'white', margin: 0, fontSize: '0.9rem', opacity: 0.9 }}>
            macOS and Linux builds are not available yet. This installer is for
            Windows only.
          </p>
        ) : null}
      </div>

      <div
        className="download-notes"
        style={{
          color: 'white',
          maxWidth: '40rem',
          marginTop: '1.5rem',
          textAlign: 'left',
        }}
      >
        <h2 style={{ fontSize: '1.1rem', marginBottom: '0.5rem' }}>
          Release notes
        </h2>
        <p style={{ whiteSpace: 'pre-wrap', lineHeight: 1.5 }}>
          {manifest.release_notes}
        </p>
      </div>

      <p
        style={{
          color: 'rgba(255,255,255,0.85)',
          fontSize: '0.85rem',
          maxWidth: '40rem',
          marginTop: '1rem',
        }}
      >
        {WINDOWS_SMARTSCREEN_NOTICE}
      </p>

      <div style={{ marginTop: '1rem', maxWidth: '40rem' }}>
        <button
          type="button"
          onClick={() => setVerifyOpen((v) => !v)}
          style={{
            background: 'transparent',
            border: '1px solid rgba(255,255,255,0.35)',
            color: 'white',
            padding: '0.4rem 0.75rem',
            borderRadius: '6px',
            cursor: 'pointer',
          }}
        >
          {verifyOpen ? 'Hide' : 'Verify download'} (SHA256)
        </button>
        {verifyOpen ? (
          <div
            style={{
              marginTop: '0.75rem',
              padding: '0.75rem',
              background: 'rgba(0,0,0,0.25)',
              borderRadius: '8px',
              fontFamily: 'monospace',
              fontSize: '0.8rem',
              wordBreak: 'break-all',
              color: '#f5f5f5',
            }}
          >
            <div>{manifest.sha256}</div>
            <div style={{ marginTop: '0.5rem' }}>
              PowerShell:{' '}
              <code>
                Get-FileHash {fileName} -Algorithm SHA256
              </code>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}
