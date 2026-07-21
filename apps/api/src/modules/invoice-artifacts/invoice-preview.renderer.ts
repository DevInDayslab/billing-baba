import sharp from 'sharp';
import type { InvoicePreviewInput } from './invoice-artifact.types';

const PREVIEW_WIDTH = 1080;
const MAX_LINE_ROWS = 12;

function escapeXml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function formatMoney(value: string): string {
  const n = Number.parseFloat(value);
  if (Number.isNaN(n)) return value;
  return n.toLocaleString('en-IN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

function truncate(value: string, max: number): string {
  const trimmed = value.trim();
  if (trimmed.length <= max) return trimmed;
  return `${trimmed.slice(0, max - 1)}…`;
}

/**
 * Renders a Vyapar-style portrait invoice preview PNG via SVG → sharp.
 * Do not screenshot PDFs; do not permanently store the result.
 */
export class InvoicePreviewRenderer {
  async render(input: InvoicePreviewInput): Promise<Buffer> {
    const lines = input.lines.slice(0, MAX_LINE_ROWS);
    const overflow = Math.max(0, input.lines.length - lines.length);

    const lineRowHeight = 36;
    const headerBlock = 220;
    const customerBlock = 90;
    const tableHeader = 40;
    const linesHeight = lines.length * lineRowHeight + (overflow > 0 ? 28 : 0);
    const totalsBlock = 160;
    const loyaltyBlock = input.loyalty ? 48 : 0;
    const footerBlock = 72;
    const padding = 48;

    const contentHeight =
      padding +
      headerBlock +
      customerBlock +
      tableHeader +
      linesHeight +
      totalsBlock +
      loyaltyBlock +
      footerBlock +
      padding;

    const height = Math.max(1400, contentHeight);

    let logoEmbed = '';
    if (input.logoBuffer && input.logoBuffer.length > 0) {
      try {
        const logoPng = await sharp(input.logoBuffer)
          .resize(96, 96, {
            fit: 'contain',
            background: { r: 255, g: 255, b: 255, alpha: 1 },
          })
          .png()
          .toBuffer();
        const b64 = logoPng.toString('base64');
        logoEmbed = `<image href="data:image/png;base64,${b64}" x="48" y="48" width="96" height="96" preserveAspectRatio="xMidYMid meet"/>`;
      } catch {
        logoEmbed = '';
      }
    }

    const companyX = logoEmbed ? 168 : 48;
    const companyLines: string[] = [];
    companyLines.push(
      `<text x="${companyX}" y="72" font-family="Helvetica, Arial, sans-serif" font-size="28" font-weight="700" fill="#0f172a">${escapeXml(truncate(input.companyName, 40))}</text>`,
    );
    let cy = 104;
    if (input.companyAddress) {
      for (const part of truncate(input.companyAddress.replace(/\n/g, ', '), 80)
        .split(', ')
        .slice(0, 2)) {
        companyLines.push(
          `<text x="${companyX}" y="${cy}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#475569">${escapeXml(part)}</text>`,
        );
        cy += 22;
      }
    }
    if (input.companyPhone) {
      companyLines.push(
        `<text x="${companyX}" y="${cy}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#475569">Phone: ${escapeXml(input.companyPhone)}</text>`,
      );
      cy += 22;
    }
    if (input.companyGstin) {
      companyLines.push(
        `<text x="${companyX}" y="${cy}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#475569">GSTIN: ${escapeXml(input.companyGstin)}</text>`,
      );
    }

    const invoiceMeta = [
      `<text x="1032" y="72" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="14" font-weight="600" fill="#64748b">TAX INVOICE</text>`,
      `<text x="1032" y="104" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="26" font-weight="700" fill="#0f172a">#${escapeXml(truncate(input.invoiceNumber, 24))}</text>`,
      `<text x="1032" y="134" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#475569">Date: ${escapeXml(input.invoiceDate)}</text>`,
    ];

    const customerY = 230;
    const customerBlockSvg = [
      `<text x="48" y="${customerY}" font-family="Helvetica, Arial, sans-serif" font-size="13" font-weight="600" fill="#64748b">BILL TO</text>`,
      `<text x="48" y="${customerY + 28}" font-family="Helvetica, Arial, sans-serif" font-size="20" font-weight="700" fill="#0f172a">${escapeXml(truncate(input.customerName, 36))}</text>`,
      input.customerPhone
        ? `<text x="48" y="${customerY + 54}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#475569">${escapeXml(input.customerPhone)}</text>`
        : '',
      `<text x="1032" y="${customerY}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="13" font-weight="600" fill="#64748b">BALANCE DUE</text>`,
      `<text x="1032" y="${customerY + 36}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="32" font-weight="700" fill="#0f172a">₹${escapeXml(formatMoney(input.dueAmount))}</text>`,
    ].join('\n');

    const tableTop = 340;
    const tableHeaderSvg = `
      <rect x="40" y="${tableTop}" width="1000" height="40" rx="8" fill="#f1f5f9"/>
      <text x="56" y="${tableTop + 26}" font-family="Helvetica, Arial, sans-serif" font-size="14" font-weight="600" fill="#64748b">ITEM</text>
      <text x="640" y="${tableTop + 26}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="14" font-weight="600" fill="#64748b">QTY</text>
      <text x="800" y="${tableTop + 26}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="14" font-weight="600" fill="#64748b">RATE</text>
      <text x="1024" y="${tableTop + 26}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="14" font-weight="600" fill="#64748b">AMOUNT</text>
    `;

    const lineSvgs = lines
      .map((line, i) => {
        const y = tableTop + 40 + i * lineRowHeight + 24;
        const qty = `${formatMoney(line.quantity)}${line.unit ? ` ${line.unit}` : ''}`;
        return `
          <text x="56" y="${y}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#0f172a">${escapeXml(truncate(line.itemName, 42))}</text>
          <text x="640" y="${y}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#334155">${escapeXml(qty)}</text>
          <text x="800" y="${y}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#334155">₹${escapeXml(formatMoney(line.unitPrice))}</text>
          <text x="1024" y="${y}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="16" font-weight="600" fill="#0f172a">₹${escapeXml(formatMoney(line.lineTotal))}</text>
        `;
      })
      .join('\n');

    const overflowSvg =
      overflow > 0
        ? `<text x="56" y="${tableTop + 40 + lines.length * lineRowHeight + 20}" font-family="Helvetica, Arial, sans-serif" font-size="14" fill="#64748b">+ ${overflow} more item${overflow === 1 ? '' : 's'}</text>`
        : '';

    const totalsY =
      tableTop +
      40 +
      lines.length * lineRowHeight +
      (overflow > 0 ? 48 : 24) +
      24;

    const loyaltySvg = input.loyalty
      ? `
        <text x="700" y="${totalsY + 120}" font-family="Helvetica, Arial, sans-serif" font-size="15" fill="#475569">Reward points</text>
        <text x="1024" y="${totalsY + 120}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="15" fill="#0f172a">+${escapeXml(formatMoney(input.loyalty.earnedPoints))}${Number.parseFloat(input.loyalty.redeemedPoints) > 0 ? ` / −${escapeXml(formatMoney(input.loyalty.redeemedPoints))}` : ''}</text>
      `
      : '';

    const footerY = height - 56;

    const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="${PREVIEW_WIDTH}" height="${height}" viewBox="0 0 ${PREVIEW_WIDTH} ${height}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <rect width="100%" height="100%" fill="#ffffff"/>
  <rect x="24" y="24" width="${PREVIEW_WIDTH - 48}" height="${height - 48}" rx="24" fill="#ffffff" stroke="#e2e8f0" stroke-width="2"/>
  ${logoEmbed}
  ${companyLines.join('\n')}
  ${invoiceMeta.join('\n')}
  <line x1="48" y1="200" x2="1032" y2="200" stroke="#e2e8f0" stroke-width="2"/>
  ${customerBlockSvg}
  ${tableHeaderSvg}
  ${lineSvgs}
  ${overflowSvg}
  <line x1="700" y1="${totalsY - 8}" x2="1032" y2="${totalsY - 8}" stroke="#e2e8f0" stroke-width="1"/>
  <text x="700" y="${totalsY + 16}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#475569">Total</text>
  <text x="1024" y="${totalsY + 16}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="16" font-weight="600" fill="#0f172a">₹${escapeXml(formatMoney(input.totalAmount))}</text>
  <text x="700" y="${totalsY + 48}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#475569">Paid</text>
  <text x="1024" y="${totalsY + 48}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#0f172a">₹${escapeXml(formatMoney(input.paidAmount))}</text>
  <text x="700" y="${totalsY + 84}" font-family="Helvetica, Arial, sans-serif" font-size="18" font-weight="700" fill="#0f172a">Balance</text>
  <text x="1024" y="${totalsY + 84}" text-anchor="end" font-family="Helvetica, Arial, sans-serif" font-size="18" font-weight="700" fill="#0f172a">₹${escapeXml(formatMoney(input.dueAmount))}</text>
  ${loyaltySvg}
  <text x="540" y="${footerY}" text-anchor="middle" font-family="Helvetica, Arial, sans-serif" font-size="14" fill="#94a3b8">Open full invoice to download PDF · Powered by Billing Baba</text>
</svg>`;

    return sharp(Buffer.from(svg))
      .resize(PREVIEW_WIDTH, null, { fit: 'inside' })
      .png({ compressionLevel: 8 })
      .toBuffer();
  }
}
