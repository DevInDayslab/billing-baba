import { useEffect, useState } from 'react';
import { fetchPaymentQr, type PaymentQrPayload } from '../api/invoices';

type ScanToPayModalProps = {
  token: string;
  open: boolean;
  onClose: () => void;
};

function formatMoney(value: string): string {
  const numeric = Number.parseFloat(value);
  if (Number.isNaN(numeric)) return value;
  return numeric.toLocaleString('en-IN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

export function ScanToPayModal({ token, open, onClose }: ScanToPayModalProps) {
  const [qr, setQr] = useState<PaymentQrPayload | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    setLoading(true);
    setError(null);
    setQr(null);

    fetchPaymentQr(token)
      .then((data) => {
        if (!cancelled) setQr(data);
      })
      .catch(() => {
        if (!cancelled) setError('Unable to load payment QR. Please try again.');
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [open, token]);

  useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-slate-900/50 p-4 sm:items-center"
      role="dialog"
      aria-modal="true"
      aria-labelledby="scan-to-pay-title"
      onClick={onClose}
    >
      <div
        className="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <h2
              id="scan-to-pay-title"
              className="text-lg font-bold text-slate-900"
            >
              Scan to Pay
            </h2>
            <p className="mt-1 text-sm text-slate-500">
              Pay instantly with any UPI app
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg px-2 py-1 text-sm font-medium text-slate-500 hover:bg-slate-100"
          >
            Close
          </button>
        </div>

        <div className="mt-6 flex flex-col items-center">
          {loading ? (
            <div className="flex h-64 w-64 items-center justify-center rounded-xl border border-slate-200 text-sm text-slate-400">
              Generating QR…
            </div>
          ) : error ? (
            <div className="flex h-64 w-full items-center justify-center rounded-xl border border-rose-200 bg-rose-50 px-4 text-center text-sm text-rose-700">
              {error}
            </div>
          ) : qr ? (
            <>
              <img
                src={qr.qr_data_url}
                alt="UPI payment QR code"
                width={256}
                height={256}
                className="h-64 w-64 rounded-xl border border-slate-200 bg-white p-2"
              />
              <p className="mt-4 text-3xl font-bold tracking-tight text-slate-900">
                ₹{formatMoney(qr.amount)}
              </p>
              <dl className="mt-4 w-full space-y-2 text-sm">
                <div className="flex justify-between gap-4">
                  <dt className="text-slate-500">Merchant</dt>
                  <dd className="font-medium text-slate-900 text-right">
                    {qr.merchant}
                  </dd>
                </div>
                <div className="flex justify-between gap-4">
                  <dt className="text-slate-500">UPI ID</dt>
                  <dd className="font-medium text-slate-900 text-right break-all">
                    {qr.upi_id}
                  </dd>
                </div>
                <div className="flex justify-between gap-4">
                  <dt className="text-slate-500">Invoice</dt>
                  <dd className="font-medium text-slate-900 text-right">
                    #{qr.invoice_number}
                  </dd>
                </div>
              </dl>
            </>
          ) : null}
        </div>

        <div className="mt-6 grid grid-cols-4 gap-3">
          {[
            { label: 'GPay', color: 'bg-blue-50 text-blue-700' },
            { label: 'PhonePe', color: 'bg-violet-50 text-violet-700' },
            { label: 'Paytm', color: 'bg-sky-50 text-sky-700' },
            { label: 'UPI', color: 'bg-emerald-50 text-emerald-700' },
          ].map((app) => (
            <div
              key={app.label}
              className={`flex h-12 items-center justify-center rounded-xl text-xs font-semibold ${app.color}`}
            >
              {app.label}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
