import { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { DOWNLOAD_URL, tryOpenApp } from '../services/deep-link';

export function AcceptedPage() {
  const { token } = useParams<{ token: string }>();

  useEffect(() => {
    if (!token) return;
    const timer = window.setTimeout(() => tryOpenApp(token), 1500);
    return () => window.clearTimeout(timer);
  }, [token]);

  return (
    <div className="rounded-2xl border border-emerald-200 bg-white p-8 text-center shadow-sm">
      <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-emerald-50 text-emerald-600">
        ✓
      </div>
      <h1 className="text-2xl font-bold text-slate-900">Invitation accepted</h1>
      <p className="mt-2 text-sm text-slate-600">
        Opening Billing Baba… If the app doesn&apos;t open automatically, use the
        button below.
      </p>
      <div className="mt-6 flex flex-col gap-3">
        {token ? (
          <button
            type="button"
            onClick={() => tryOpenApp(token)}
            className="rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white hover:bg-slate-800"
          >
            Open Billing Baba
          </button>
        ) : null}
        <a
          href={DOWNLOAD_URL}
          className="rounded-xl border border-slate-300 px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50"
        >
          Download Billing Baba
        </a>
      </div>
    </div>
  );
}
