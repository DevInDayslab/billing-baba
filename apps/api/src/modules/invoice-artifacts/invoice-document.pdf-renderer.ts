import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import type { Browser } from 'puppeteer-core' with {
  'resolution-mode': 'import',
};

/** Prefer API assets; fall back when running from compiled dist. */
function resolveFontPath(fileName: string): string {
  const candidates = [
    join(process.cwd(), 'assets', 'fonts', fileName),
    join(__dirname, '../../../../assets/fonts', fileName),
    join(__dirname, '../../../assets/fonts', fileName),
  ];
  for (const candidate of candidates) {
    if (existsSync(candidate)) return candidate;
  }
  throw new Error(`Font not found: ${fileName}`);
}

function fontDataUri(fileName: string): string {
  const bytes = readFileSync(resolveFontPath(fileName));
  return `data:font/ttf;base64,${bytes.toString('base64')}`;
}

let cachedFontCss: string | null = null;

function invoiceFontFaceCss(): string {
  if (cachedFontCss) return cachedFontCss;
  const interRegular = fontDataUri('Inter-Regular.ttf');
  const interSemiBold = fontDataUri('Inter-SemiBold.ttf');
  const interBold = fontDataUri('Inter-Bold.ttf');
  const noto = fontDataUri('NotoSans-Regular.ttf');
  cachedFontCss = `
@font-face {
  font-family: 'BB Inter';
  font-weight: 400;
  src: url('${interRegular}') format('truetype');
}
@font-face {
  font-family: 'BB Inter';
  font-weight: 600;
  src: url('${interSemiBold}') format('truetype');
}
@font-face {
  font-family: 'BB Inter';
  font-weight: 700;
  src: url('${interBold}') format('truetype');
}
@font-face {
  font-family: 'BB Noto Sans';
  font-weight: 400;
  src: url('${noto}') format('truetype');
}
`.trim();
  return cachedFontCss;
}

export type InvoiceDocumentLine = {
  itemName: string;
  quantity: string;
  unit: string;
  unitPrice: string;
  lineTotal: string;
  taxAmount: string;
  discountAmount: string;
};

export type InvoiceDocumentModel = {
  companyName: string;
  companyAddress: string | null;
  companyPhone: string | null;
  companyEmail: string | null;
  companyGstin: string | null;
  /** data: URL or https URL for logo */
  logoSrc: string | null;
  invoiceNumber: string;
  invoiceDate: string;
  paymentStatus: 'paid' | 'partial' | 'unpaid';
  customerName: string | null;
  customerPhone: string | null;
  customerEmail: string | null;
  customerGstin: string | null;
  lines: InvoiceDocumentLine[];
  subtotal: string;
  discountTotal: string;
  taxAmount: string;
  totalAmount: string;
  paidAmount: string;
  dueAmount: string;
  notes: string | null;
  loyalty: {
    earnedPoints: string;
    redeemedPoints: string;
  } | null;
  qrDataUrl: string | null;
  qrAmount: string | null;
  qrUpiId: string | null;
  qrMerchant: string | null;
};

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function formatMoney(value: string): string {
  const n = Number.parseFloat(value);
  if (Number.isNaN(n)) return escapeHtml(value);
  return n.toLocaleString('en-IN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

/** Rupee amounts use Noto Sans so U+20B9 embeds correctly in the PDF. */
function inr(value: string): string {
  return `<span class="money">₹${formatMoney(value)}</span>`;
}

function paymentStatusLabel(
  status: InvoiceDocumentModel['paymentStatus'],
): string {
  switch (status) {
    case 'paid':
      return 'Paid';
    case 'partial':
      return 'Partially paid';
    default:
      return 'Unpaid';
  }
}

function paymentStatusClass(
  status: InvoiceDocumentModel['paymentStatus'],
): string {
  switch (status) {
    case 'paid':
      return 'badge-paid';
    case 'partial':
      return 'badge-partial';
    default:
      return 'badge-unpaid';
  }
}

/**
 * Canonical public-invoice HTML — mirrors `apps/website` InvoiceView print layout.
 * Browser print, Chromium PDF, and the public page share this visual language.
 */
export function renderInvoiceDocumentHtml(model: InvoiceDocumentModel): string {
  const discountTotal = Number.parseFloat(model.discountTotal);
  const linesHtml = model.lines
    .map((line) => {
      const discount = Number.parseFloat(line.discountAmount);
      return `
        <tr>
          <td class="item">
            <p class="item-name">${escapeHtml(line.itemName)}</p>
            ${
              discount > 0
                ? `<p class="item-discount">Discount ${inr(line.discountAmount)}</p>`
                : ''
            }
          </td>
          <td class="num">${formatMoney(line.quantity)} ${escapeHtml(line.unit)}</td>
          <td class="num">${inr(line.unitPrice)}</td>
          <td class="num">${inr(line.taxAmount)}</td>
          <td class="num amount">${inr(line.lineTotal)}</td>
        </tr>`;
    })
    .join('');

  const customerHtml = model.customerName
    ? `
      <p class="customer-name">${escapeHtml(model.customerName)}</p>
      ${model.customerPhone ? `<p>${escapeHtml(model.customerPhone)}</p>` : ''}
      ${model.customerEmail ? `<p>${escapeHtml(model.customerEmail)}</p>` : ''}
      ${
        model.customerGstin
          ? `<p class="gstin">GSTIN: ${escapeHtml(model.customerGstin)}</p>`
          : ''
      }`
    : `<p class="muted">Walk-in customer</p>`;

  const qrHtml =
    model.qrDataUrl && model.qrAmount
      ? `
    <section class="qr-section">
      <h2>Scan to pay</h2>
      <div class="qr-row">
        <img class="qr" src="${model.qrDataUrl}" alt="UPI payment QR code" width="160" height="160" />
        <div class="qr-meta">
          <p class="qr-amount">${inr(model.qrAmount)}</p>
          ${model.qrUpiId ? `<p>UPI: ${escapeHtml(model.qrUpiId)}</p>` : ''}
          ${
            model.qrMerchant
              ? `<p>Merchant: ${escapeHtml(model.qrMerchant)}</p>`
              : ''
          }
        </div>
      </div>
    </section>`
      : '';

  const loyaltyHtml = model.loyalty
    ? `
      <div class="totals-row">
        <span>Reward points</span>
        <span>+${formatMoney(model.loyalty.earnedPoints)}${
          Number.parseFloat(model.loyalty.redeemedPoints) > 0
            ? ` / −${formatMoney(model.loyalty.redeemedPoints)}`
            : ''
        }</span>
      </div>`
    : '';

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Tax Invoice ${escapeHtml(model.invoiceNumber)}</title>
  <style>
    ${invoiceFontFaceCss()}
    * { box-sizing: border-box; }
    html, body {
      margin: 0;
      padding: 0;
      background: #fff;
      color: #0f172a;
      font-family: 'BB Inter', 'BB Noto Sans', system-ui, sans-serif;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }
    .money {
      font-family: 'BB Noto Sans', 'BB Inter', sans-serif;
    }
    .sheet {
      width: 100%;
      max-width: 720px;
      margin: 0 auto;
      border: 1px solid #e2e8f0;
      background: #fff;
      overflow: hidden;
    }
    header {
      padding: 24px 32px;
      border-bottom: 1px solid #f1f5f9;
    }
    .header-row {
      display: flex;
      justify-content: space-between;
      gap: 24px;
      align-items: flex-start;
    }
    .brand {
      display: flex;
      gap: 16px;
      align-items: flex-start;
    }
    .logo {
      width: 64px;
      height: 64px;
      object-fit: contain;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 4px;
      background: #fff;
      flex-shrink: 0;
    }
    .eyebrow {
      margin: 0;
      font-size: 12px;
      font-weight: 600;
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: #64748b;
    }
    h1 {
      margin: 4px 0 0;
      font-size: 28px;
      font-weight: 700;
      color: #0f172a;
    }
    .company-address {
      margin: 8px 0 0;
      max-width: 28rem;
      font-size: 14px;
      color: #475569;
      white-space: pre-line;
    }
    .company-meta {
      margin-top: 12px;
      font-size: 14px;
      color: #475569;
      line-height: 1.45;
    }
    .company-meta p { margin: 0; }
    .meta {
      text-align: right;
    }
    .meta .label {
      margin: 0;
      font-size: 14px;
      font-weight: 500;
      color: #64748b;
    }
    .meta .number {
      margin: 0;
      font-size: 20px;
      font-weight: 600;
      color: #0f172a;
    }
    .meta .date {
      margin: 8px 0 0;
      font-size: 14px;
      color: #475569;
    }
    .badge {
      display: inline-flex;
      margin-top: 12px;
      padding: 4px 12px;
      border-radius: 999px;
      font-size: 12px;
      font-weight: 600;
      ring: 1px;
      border: 1px solid;
    }
    .badge-paid { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
    .badge-partial { background: #fffbeb; color: #92400e; border-color: #fde68a; }
    .badge-unpaid { background: #fff1f2; color: #9f1239; border-color: #fecdd3; }
    .bill-due {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
      padding: 24px 32px;
      border-bottom: 1px solid #f1f5f9;
    }
    .section-label {
      margin: 0;
      font-size: 12px;
      font-weight: 600;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      color: #64748b;
    }
    .customer-name {
      margin: 8px 0 0;
      font-size: 16px;
      font-weight: 600;
      color: #0f172a;
    }
    .bill-due p { margin: 2px 0; font-size: 14px; color: #1e293b; }
    .bill-due .muted { color: #64748b; margin-top: 8px; }
    .bill-due .gstin { margin-top: 4px; }
    .due-block { text-align: right; }
    .due-amount {
      margin: 8px 0 0;
      font-size: 30px;
      font-weight: 700;
      letter-spacing: -0.02em;
      color: #0f172a;
    }
    .due-sub {
      margin: 4px 0 0;
      font-size: 14px;
      color: #475569;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
      text-align: left;
    }
    thead th {
      padding: 12px 12px;
      font-size: 12px;
      font-weight: 600;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      color: #64748b;
      border-bottom: 1px solid #f1f5f9;
    }
    thead th:first-child { padding-left: 32px; }
    thead th:last-child { padding-right: 32px; }
    tbody td {
      padding: 12px;
      border-bottom: 1px solid #f1f5f9;
      color: #1e293b;
      vertical-align: top;
    }
    tbody td:first-child { padding-left: 32px; }
    tbody td:last-child { padding-right: 32px; }
    .item-name { margin: 0; font-weight: 500; color: #0f172a; }
    .item-discount { margin: 4px 0 0; font-size: 12px; color: #64748b; }
    .num { text-align: right; white-space: nowrap; }
    .amount { font-weight: 500; }
    .totals-wrap {
      padding: 24px 32px;
      border-top: 1px solid #f1f5f9;
    }
    .totals {
      margin-left: auto;
      width: 100%;
      max-width: 20rem;
      font-size: 14px;
    }
    .totals-row {
      display: flex;
      justify-content: space-between;
      color: #475569;
      margin: 0 0 8px;
    }
    .totals-row.strong {
      color: #0f172a;
      font-size: 16px;
      font-weight: 600;
      border-top: 1px solid #f1f5f9;
      padding-top: 8px;
      margin-top: 4px;
    }
    .notes {
      margin: 24px 0 0;
      font-size: 14px;
      color: #475569;
    }
    .notes strong { color: #1e293b; font-weight: 500; }
    .qr-section {
      padding: 24px 32px;
      border-top: 1px solid #f1f5f9;
    }
    .qr-section h2 {
      margin: 0;
      font-size: 12px;
      font-weight: 600;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      color: #64748b;
    }
    .qr-row {
      margin-top: 16px;
      display: flex;
      gap: 16px;
      align-items: center;
    }
    .qr {
      width: 160px;
      height: 160px;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 8px;
      background: #fff;
    }
    .qr-meta { font-size: 14px; color: #475569; }
    .qr-amount {
      margin: 0 0 8px;
      font-size: 24px;
      font-weight: 700;
      color: #0f172a;
    }
    .sign-footer {
      padding: 24px 32px 16px;
      border-top: 1px solid #f1f5f9;
      display: flex;
      justify-content: flex-end;
    }
    .sign {
      width: 160px;
      text-align: center;
      font-size: 12px;
      color: #64748b;
    }
    .sign-line {
      border-top: 1px solid #94a3b8;
      margin-bottom: 8px;
      padding-top: 28px;
    }
    footer.powered {
      padding: 16px 32px;
      border-top: 1px solid #f1f5f9;
      text-align: center;
      font-size: 12px;
      color: #94a3b8;
    }
    @page { size: A4 portrait; margin: 12mm; }
  </style>
</head>
<body>
  <article class="sheet">
    <header>
      <div class="header-row">
        <div class="brand">
          ${
            model.logoSrc
              ? `<img class="logo" src="${model.logoSrc}" alt="" />`
              : ''
          }
          <div>
            <p class="eyebrow">Tax Invoice</p>
            <h1>${escapeHtml(model.companyName)}</h1>
            ${
              model.companyAddress
                ? `<p class="company-address">${escapeHtml(model.companyAddress)}</p>`
                : ''
            }
            <div class="company-meta">
              ${model.companyGstin ? `<p>GSTIN: ${escapeHtml(model.companyGstin)}</p>` : ''}
              ${model.companyPhone ? `<p>Phone: ${escapeHtml(model.companyPhone)}</p>` : ''}
              ${model.companyEmail ? `<p>Email: ${escapeHtml(model.companyEmail)}</p>` : ''}
            </div>
          </div>
        </div>
        <div class="meta">
          <p class="label">Invoice</p>
          <p class="number">#${escapeHtml(model.invoiceNumber)}</p>
          <p class="date">Date: ${escapeHtml(model.invoiceDate)}</p>
          <span class="badge ${paymentStatusClass(model.paymentStatus)}">${paymentStatusLabel(model.paymentStatus)}</span>
        </div>
      </div>
    </header>

    <section class="bill-due">
      <div>
        <p class="section-label">Bill to</p>
        ${customerHtml}
      </div>
      <div class="due-block">
        <p class="section-label">Amount due</p>
        <p class="due-amount">${inr(model.dueAmount)}</p>
        <p class="due-sub">Total ${inr(model.totalAmount)} · Paid ${inr(model.paidAmount)}</p>
      </div>
    </section>

    <section>
      <table>
        <thead>
          <tr>
            <th>Item</th>
            <th class="num">Qty</th>
            <th class="num">Rate</th>
            <th class="num">Tax</th>
            <th class="num">Amount</th>
          </tr>
        </thead>
        <tbody>
          ${linesHtml || '<tr><td colspan="5" class="item">No line items</td></tr>'}
        </tbody>
      </table>
    </section>

    <section class="totals-wrap">
      <div class="totals">
        <div class="totals-row"><span>Subtotal</span><span>${inr(model.subtotal)}</span></div>
        ${
          discountTotal > 0
            ? `<div class="totals-row"><span>Discount</span><span>−${inr(model.discountTotal)}</span></div>`
            : ''
        }
        <div class="totals-row"><span>Tax</span><span>${inr(model.taxAmount)}</span></div>
        <div class="totals-row strong"><span>Total</span><span>${inr(model.totalAmount)}</span></div>
        <div class="totals-row"><span>Paid</span><span>${inr(model.paidAmount)}</span></div>
        <div class="totals-row strong"><span>Due</span><span>${inr(model.dueAmount)}</span></div>
        ${loyaltyHtml}
      </div>
      ${
        model.notes
          ? `<p class="notes"><strong>Notes: </strong>${escapeHtml(model.notes)}</p>`
          : ''
      }
    </section>

    ${qrHtml}

    <div class="sign-footer">
      <div class="sign">
        <div class="sign-line"></div>
        Authorized Signatory
      </div>
    </div>

    <footer class="powered">Powered by Billing Baba</footer>
  </article>
</body>
</html>`;
}

let browserPromise: Promise<Browser> | null = null;

async function getBrowser(): Promise<Browser> {
  if (!browserPromise) {
    browserPromise = (async () => {
      const puppeteer = await import('puppeteer-core');
      const executablePath =
        process.env.CHROMIUM_PATH ||
        process.env.PUPPETEER_EXECUTABLE_PATH ||
        (process.platform === 'darwin'
          ? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
          : process.platform === 'linux'
            ? await (async () => {
                const chromium = await import('@sparticuz/chromium');
                return chromium.default.executablePath();
              })()
            : undefined);

      if (!executablePath) {
        throw new Error(
          'No Chromium executable found. Set CHROMIUM_PATH or install Google Chrome.',
        );
      }

      const args =
        process.platform === 'linux'
          ? (await import('@sparticuz/chromium')).default.args
          : [
              '--no-sandbox',
              '--disable-setuid-sandbox',
              '--font-render-hinting=none',
            ];

      return puppeteer.default.launch({
        executablePath,
        headless: true,
        args,
      });
    })().catch((error) => {
      browserPromise = null;
      throw error;
    });
  }
  return browserPromise;
}

/**
 * Renders the canonical invoice HTML to an A4 PDF via Chromium.
 * Embeds Inter + Noto Sans so ₹ (U+20B9) prints correctly.
 */
export class InvoiceDocumentPdfRenderer {
  async render(model: InvoiceDocumentModel): Promise<Buffer> {
    const html = renderInvoiceDocumentHtml(model);
    const browser = await getBrowser();
    const page = await browser.newPage();
    try {
      await page.setContent(html, { waitUntil: 'load' });
      await page.evaluate(async () => {
        const doc = (
          globalThis as { document?: { fonts?: { ready?: Promise<void> } } }
        ).document;
        if (doc?.fonts?.ready) {
          await doc.fonts.ready;
        }
      });
      const pdf = await page.pdf({
        format: 'A4',
        printBackground: true,
        preferCSSPageSize: true,
        margin: { top: '10mm', right: '10mm', bottom: '10mm', left: '10mm' },
      });
      return Buffer.from(pdf);
    } finally {
      await page.close().catch(() => undefined);
    }
  }
}
