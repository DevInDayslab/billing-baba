import { useEffect, useRef, useState } from 'react';
import {
  fetchInvoicePdfDownload,
  fetchPaymentQr,
  type PaymentQrPayload,
  type PublicInvoice,
} from '../api/invoices';
import { ScanToPayModal } from './ScanToPayModal';

function formatMoney(value: string): string {
  const numeric = Number.parseFloat(value);
  if (Number.isNaN(numeric)) return value;
  return numeric.toLocaleString('en-IN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString(undefined, {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function paymentStatusLabel(status: PublicInvoice['invoice']['payment_status']) {
  switch (status) {
    case 'paid':
      return 'Paid';
    case 'partial':
      return 'Partially paid';
    default:
      return 'Unpaid';
  }
}

function paymentStatusClass(status: PublicInvoice['invoice']['payment_status']) {
  switch (status) {
    case 'paid':
      return 'bg-emerald-50 text-emerald-800 ring-emerald-200';
    case 'partial':
      return 'bg-amber-50 text-amber-800 ring-amber-200';
    default:
      return 'bg-rose-50 text-rose-800 ring-rose-200';
  }
}

function safePdfFileName(invoiceLabel: string, companyName: string): string {
  const raw = `invoice-${invoiceLabel}-${companyName}`;
  const safe = raw.replace(/[^\w.-]+/g, '_').replace(/_+/g, '_').slice(0, 120);
  return `${safe || 'invoice'}.pdf`;
}

function triggerBrowserDownload(url: string, fileName: string) {
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = fileName;
  anchor.rel = 'noopener';
  anchor.target = '_blank';
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
}

type InvoiceViewProps = {
  invoice: PublicInvoice;
};

export function InvoiceView({ invoice }: InvoiceViewProps) {
  const doc = invoice.invoice;
  const invoiceLabel = doc.document_number ?? doc.document_series;
  const shareUrl = invoice.share?.url ?? invoice.share_url;
  const scanToPayEnabled = invoice.payment?.scan_to_pay_enabled === true;
  const sheetRef = useRef<HTMLElement>(null);
  const [scanOpen, setScanOpen] = useState(false);
  const [shareHint, setShareHint] = useState<string | null>(null);
  const [pdfBusy, setPdfBusy] = useState(false);
  const [pdfError, setPdfError] = useState<string | null>(null);
  const [paymentQr, setPaymentQr] = useState<PaymentQrPayload | null>(null);

  useEffect(() => {
    if (!scanToPayEnabled) {
      setPaymentQr(null);
      return;
    }

    let cancelled = false;
    fetchPaymentQr(invoice.token)
      .then((data) => {
        if (!cancelled) setPaymentQr(data);
      })
      .catch(() => {
        if (!cancelled) setPaymentQr(null);
      });

    return () => {
      cancelled = true;
    };
  }, [invoice.token, scanToPayEnabled]);

  async function handleShare() {
    const title = `Invoice #${invoiceLabel} — ${invoice.company.name}`;
    const text = `View invoice #${invoiceLabel} from ${invoice.company.name}`;
    try {
      if (navigator.share) {
        await navigator.share({ title, text, url: shareUrl });
        return;
      }
      await navigator.clipboard.writeText(shareUrl);
      setShareHint('Link copied');
      window.setTimeout(() => setShareHint(null), 2000);
    } catch {
      try {
        await navigator.clipboard.writeText(shareUrl);
        setShareHint('Link copied');
        window.setTimeout(() => setShareHint(null), 2000);
      } catch {
        setShareHint('Unable to share');
        window.setTimeout(() => setShareHint(null), 2000);
      }
    }
  }

  async function handleDownloadPdf() {
    if (pdfBusy) return;

    setPdfBusy(true);
    setPdfError(null);
    try {
      const result = await fetchInvoicePdfDownload(invoice.token);
      const fileName =
        result.file_name?.trim() ||
        safePdfFileName(invoiceLabel, invoice.company.name);
      triggerBrowserDownload(result.download_url, fileName);
    } catch {
      setPdfError('Unable to download PDF. Try Print → Save as PDF.');
      window.setTimeout(() => setPdfError(null), 4000);
    } finally {
      setPdfBusy(false);
    }
  }

  return (
    <div className="space-y-6 pb-24 sm:pb-6">
      <article
        ref={sheetRef}
        className="invoice-sheet overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm print:shadow-none"
      >
        <header className="border-b border-slate-100 px-6 py-6 sm:px-8">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div className="flex gap-4">
              {invoice.company.logo_url ? (
                <img
                  src={invoice.company.logo_url}
                  alt={`${invoice.company.name} logo`}
                  className="h-16 w-16 shrink-0 rounded-xl border border-slate-200 bg-white object-contain p-1"
                  crossOrigin="anonymous"
                />
              ) : null}
              <div>
                <p className="text-xs font-semibold uppercase tracking-widest text-slate-500">
                  Tax Invoice
                </p>
                <h1 className="mt-1 text-2xl font-bold text-slate-900 sm:text-3xl">
                  {invoice.company.name}
                </h1>
                {invoice.company.address ? (
                  <p className="mt-2 max-w-md text-sm text-slate-600 whitespace-pre-line">
                    {invoice.company.address}
                  </p>
                ) : null}
                <div className="mt-3 space-y-0.5 text-sm text-slate-600">
                  {invoice.company.gstin ? (
                    <p>GSTIN: {invoice.company.gstin}</p>
                  ) : null}
                  {invoice.company.phone ? (
                    <p>Phone: {invoice.company.phone}</p>
                  ) : null}
                  {invoice.company.email ? (
                    <p>Email: {invoice.company.email}</p>
                  ) : null}
                </div>
              </div>
            </div>

            <div className="text-left sm:text-right">
              <p className="text-sm font-medium text-slate-500">Invoice</p>
              <p className="text-xl font-semibold text-slate-900">
                #{invoiceLabel}
              </p>
              <p className="mt-2 text-sm text-slate-600">
                Date: {formatDate(doc.document_date)}
              </p>
              <span
                className={`mt-3 inline-flex rounded-full px-3 py-1 text-xs font-semibold ring-1 ring-inset ${paymentStatusClass(doc.payment_status)}`}
              >
                {paymentStatusLabel(doc.payment_status)}
              </span>
            </div>
          </div>
        </header>

        <section className="grid gap-6 border-b border-slate-100 px-6 py-6 sm:grid-cols-2 sm:px-8">
          <div>
            <h2 className="text-xs font-semibold uppercase tracking-wide text-slate-500">
              Bill to
            </h2>
            {invoice.customer ? (
              <div className="mt-2 text-sm text-slate-800">
                <p className="text-base font-semibold text-slate-900">
                  {invoice.customer.name}
                </p>
                {invoice.customer.mobile ? <p>{invoice.customer.mobile}</p> : null}
                {invoice.customer.email ? <p>{invoice.customer.email}</p> : null}
                {invoice.customer.gstin ? (
                  <p className="mt-1">GSTIN: {invoice.customer.gstin}</p>
                ) : null}
              </div>
            ) : (
              <p className="mt-2 text-sm text-slate-500">Walk-in customer</p>
            )}
          </div>

          <div className="sm:text-right">
            <h2 className="text-xs font-semibold uppercase tracking-wide text-slate-500">
              Amount due
            </h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-slate-900">
              ₹{formatMoney(doc.due_amount)}
            </p>
            <p className="mt-1 text-sm text-slate-600">
              Total ₹{formatMoney(doc.total_amount)} · Paid ₹
              {formatMoney(doc.paid_amount)}
            </p>
          </div>
        </section>

        <section className="px-0 py-2 sm:px-2">
          <div className="overflow-x-auto">
            <table className="min-w-full text-left text-sm">
              <thead className="border-b border-slate-100 text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th className="px-6 py-3 font-semibold sm:px-8">Item</th>
                  <th className="px-3 py-3 font-semibold text-right">Qty</th>
                  <th className="px-3 py-3 font-semibold text-right">Rate</th>
                  <th className="px-3 py-3 font-semibold text-right">Tax</th>
                  <th className="px-6 py-3 font-semibold text-right sm:px-8">
                    Amount
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {invoice.lines.map((line, index) => {
                  const tax =
                    Number.parseFloat(line.cgst_amount) +
                    Number.parseFloat(line.sgst_amount) +
                    Number.parseFloat(line.igst_amount);
                  return (
                    <tr
                      key={`${line.item_name}-${index}`}
                      className="text-slate-800"
                    >
                      <td className="px-6 py-3 sm:px-8">
                        <p className="font-medium text-slate-900">
                          {line.item_name}
                        </p>
                        {Number.parseFloat(line.discount_amount) > 0 ? (
                          <p className="text-xs text-slate-500">
                            Discount ₹{formatMoney(line.discount_amount)}
                          </p>
                        ) : null}
                      </td>
                      <td className="px-3 py-3 text-right whitespace-nowrap">
                        {formatMoney(line.quantity)} {line.unit}
                      </td>
                      <td className="px-3 py-3 text-right whitespace-nowrap">
                        ₹{formatMoney(line.unit_price)}
                      </td>
                      <td className="px-3 py-3 text-right whitespace-nowrap">
                        ₹{formatMoney(String(tax))}
                      </td>
                      <td className="px-6 py-3 text-right font-medium whitespace-nowrap sm:px-8">
                        ₹{formatMoney(line.line_total)}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </section>

        <section className="border-t border-slate-100 px-6 py-6 sm:px-8">
          <dl className="ml-auto w-full max-w-xs space-y-2 text-sm">
            <div className="flex justify-between text-slate-600">
              <dt>Subtotal</dt>
              <dd>₹{formatMoney(doc.subtotal)}</dd>
            </div>
            {Number.parseFloat(doc.discount_total) > 0 ? (
              <div className="flex justify-between text-slate-600">
                <dt>Discount</dt>
                <dd>−₹{formatMoney(doc.discount_total)}</dd>
              </div>
            ) : null}
            <div className="flex justify-between text-slate-600">
              <dt>Tax</dt>
              <dd>₹{formatMoney(doc.tax_amount)}</dd>
            </div>
            <div className="flex justify-between border-t border-slate-100 pt-2 text-base font-semibold text-slate-900">
              <dt>Total</dt>
              <dd>₹{formatMoney(doc.total_amount)}</dd>
            </div>
            <div className="flex justify-between text-slate-600">
              <dt>Paid</dt>
              <dd>₹{formatMoney(doc.paid_amount)}</dd>
            </div>
            <div className="flex justify-between text-base font-semibold text-slate-900">
              <dt>Due</dt>
              <dd>₹{formatMoney(doc.due_amount)}</dd>
            </div>
            {doc.loyalty ? (
              <div className="flex justify-between text-slate-600">
                <dt>Reward points</dt>
                <dd>
                  +{formatMoney(doc.loyalty.earned_points)}
                  {Number.parseFloat(doc.loyalty.redeemed_points) > 0
                    ? ` / −${formatMoney(doc.loyalty.redeemed_points)}`
                    : ''}
                </dd>
              </div>
            ) : null}
          </dl>

          {doc.notes ? (
            <p className="mt-6 text-sm text-slate-600">
              <span className="font-medium text-slate-800">Notes: </span>
              {doc.notes}
            </p>
          ) : null}
        </section>

        {scanToPayEnabled && paymentQr ? (
          <section className="invoice-print-only border-t border-slate-100 px-6 py-6 sm:px-8">
            <h2 className="text-xs font-semibold uppercase tracking-wide text-slate-500">
              Scan to pay
            </h2>
            <div className="mt-4 flex flex-col items-start gap-4 sm:flex-row sm:items-center">
              <img
                src={paymentQr.qr_data_url}
                alt="UPI payment QR code"
                width={160}
                height={160}
                className="h-40 w-40 rounded-xl border border-slate-200 bg-white p-2"
              />
              <div className="text-sm text-slate-600">
                <p className="text-2xl font-bold tracking-tight text-slate-900">
                  ₹{formatMoney(paymentQr.amount)}
                </p>
                <p className="mt-2">UPI: {paymentQr.upi_id}</p>
                <p>Merchant: {paymentQr.merchant}</p>
              </div>
            </div>
          </section>
        ) : null}

        {scanToPayEnabled ? (
          <section className="invoice-screen-only border-t border-slate-100 bg-slate-50 px-6 py-6 sm:px-8 print:hidden">
            <button
              type="button"
              onClick={() => setScanOpen(true)}
              className="w-full rounded-xl bg-emerald-600 px-4 py-3 text-sm font-semibold text-white transition hover:bg-emerald-700 sm:w-auto"
            >
              Scan to Pay · ₹{formatMoney(invoice.payment.due_amount)}
            </button>
            {invoice.payment.upi_id ? (
              <p className="mt-2 text-xs text-slate-500">
                UPI: {invoice.payment.upi_id}
              </p>
            ) : null}
          </section>
        ) : null}

        <footer className="invoice-print-only border-t border-slate-100 px-6 py-4 text-center text-xs text-slate-400 sm:px-8">
          Powered by Billing Baba
        </footer>
      </article>

      <div className="fixed inset-x-0 bottom-0 z-40 border-t border-slate-200 bg-white/95 p-3 backdrop-blur print:hidden sm:static sm:border-0 sm:bg-transparent sm:p-0 sm:backdrop-blur-none">
        <div className="mx-auto flex max-w-3xl flex-col gap-2 sm:flex-row sm:justify-end">
          <button
            type="button"
            onClick={() => window.print()}
            className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-800 transition hover:bg-slate-50"
          >
            Print
          </button>
          <button
            type="button"
            onClick={handleShare}
            className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-800 transition hover:bg-slate-50"
          >
            {shareHint ?? 'Share'}
          </button>
          {scanToPayEnabled ? (
            <button
              type="button"
              onClick={() => setScanOpen(true)}
              className="rounded-xl bg-emerald-600 px-4 py-3 text-sm font-semibold text-white transition hover:bg-emerald-700 sm:hidden"
            >
              Scan to Pay
            </button>
          ) : null}
          <button
            type="button"
            disabled={pdfBusy}
            onClick={() => {
              void handleDownloadPdf();
            }}
            title="Download invoice PDF"
            className={
              pdfBusy
                ? 'cursor-wait rounded-xl bg-slate-900/60 px-4 py-3 text-sm font-semibold text-white'
                : 'rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white transition hover:bg-slate-800'
            }
          >
            {pdfBusy ? 'Preparing PDF…' : 'Download PDF'}
          </button>
        </div>
        {pdfError ? (
          <p className="mx-auto mt-2 max-w-3xl text-center text-xs text-rose-600 sm:text-right">
            {pdfError}
          </p>
        ) : null}
      </div>

      <ScanToPayModal
        token={invoice.token}
        open={scanOpen}
        onClose={() => setScanOpen(false)}
      />
    </div>
  );
}
