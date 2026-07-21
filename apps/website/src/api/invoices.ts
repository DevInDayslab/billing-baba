import { useQuery } from '@tanstack/react-query';
import { apiFetch } from './client';

export type PublicInvoiceLine = {
  item_name: string;
  quantity: string;
  unit: string;
  unit_price: string;
  discount_amount: string;
  tax_type: string;
  tax_rate: string;
  cgst_amount: string;
  sgst_amount: string;
  igst_amount: string;
  line_total: string;
};

export type PublicInvoiceLoyalty = {
  earned_points: string;
  redeemed_points: string;
  points_available: string | null;
};

export type PublicInvoice = {
  token: string;
  invoice: {
    document_number: string | null;
    document_series: string;
    document_type: string;
    document_date: string;
    status: string;
    notes: string | null;
    subtotal: string;
    discount_total: string;
    tax_amount: string;
    total_amount: string;
    paid_amount: string;
    due_amount: string;
    payment_status: 'unpaid' | 'partial' | 'paid';
    loyalty: PublicInvoiceLoyalty | null;
  };
  company: {
    name: string;
    gstin: string | null;
    address: string | null;
    phone: string | null;
    email: string | null;
    state_code: string;
    logo_url: string | null;
    upi_id: string | null;
  };
  customer: {
    name: string;
    mobile: string | null;
    email: string | null;
    gstin: string | null;
    state_code: string | null;
  } | null;
  lines: PublicInvoiceLine[];
  payment: {
    upi_id: string | null;
    due_amount: string;
    scan_to_pay_enabled: boolean;
  };
  share: {
    url: string;
    token: string;
    expires_at: string | null;
  };
  share_url: string;
  expires_at: string | null;
  /** Canonical download endpoint: GET returns signed URL for stored invoice.pdf. */
  pdf_download_path: string | null;
};

export type PublicInvoicePdfDownload = {
  download_url: string;
  file_name: string;
  expires_at: string | null;
  cached: boolean;
};

export type PaymentQrPayload = {
  qr_data_url: string;
  amount: string;
  merchant: string;
  upi_id: string;
  invoice_number: string;
  upi_payload: string;
};

export function usePublicInvoice(token: string | undefined) {
  return useQuery({
    queryKey: ['public-invoice', token],
    enabled: Boolean(token),
    queryFn: () =>
      apiFetch<PublicInvoice>(`/${token}`, {
        basePath: '/public/invoices',
      }),
    retry: false,
  });
}

export async function fetchPaymentQr(token: string): Promise<PaymentQrPayload> {
  return apiFetch<PaymentQrPayload>(`/${token}/payment-qr?format=json`, {
    basePath: '/public/invoices',
  });
}

export async function fetchInvoicePdfDownload(
  token: string,
): Promise<PublicInvoicePdfDownload> {
  return apiFetch<PublicInvoicePdfDownload>(`/${token}/download`, {
    basePath: '/public/invoices',
  });
}
