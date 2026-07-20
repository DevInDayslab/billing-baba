import QRCode from 'qrcode';
import type {
  PaymentQrInput,
  PaymentQrResult,
} from './invoice-artifact.types';

/**
 * Builds a standard Bharat UPI deep-link and renders a QR PNG on demand.
 * Never persists QR images — generate per request.
 */
export class PaymentQrService {
  buildUpiPayload(input: PaymentQrInput): string | null {
    const upiId = input.upiId.trim();
    if (!upiId) return null;

    const due = Number.parseFloat(input.dueAmount);
    if (!(due > 0) || Number.isNaN(due)) return null;

    const amount = due.toFixed(2);
    const params = new URLSearchParams({
      pa: upiId,
      pn: input.companyName.trim() || 'Merchant',
      am: amount,
      mam: '0.01',
      tn: `Invoice_${input.invoiceNumber.replace(/[^\w.-]+/g, '_')}`,
      cu: 'INR',
    });

    return `upi://pay?${params.toString()}`;
  }

  async generate(input: PaymentQrInput): Promise<PaymentQrResult | null> {
    const upiPayload = this.buildUpiPayload(input);
    if (!upiPayload) return null;

    const buffer = await QRCode.toBuffer(upiPayload, {
      type: 'png',
      width: 320,
      margin: 2,
      errorCorrectionLevel: 'M',
    });

    const dataUrl = await QRCode.toDataURL(upiPayload, {
      width: 320,
      margin: 2,
      errorCorrectionLevel: 'M',
    });

    return {
      buffer,
      dataUrl,
      upiPayload,
      amount: Number.parseFloat(input.dueAmount).toFixed(2),
      merchant: input.companyName.trim() || 'Merchant',
      upiId: input.upiId.trim(),
      invoiceNumber: input.invoiceNumber,
    };
  }
}
