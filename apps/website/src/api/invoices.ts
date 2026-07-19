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
  };
  company: {
    name: string;
    gstin: string | null;
    address: string | null;
    phone: string | null;
    email: string | null;
    state_code: string;
    logo_url: string | null;
  };
  customer: {
    name: string;
    mobile: string | null;
    email: string | null;
    gstin: string | null;
    state_code: string | null;
  } | null;
  lines: PublicInvoiceLine[];
  share_url: string;
  expires_at: string | null;
  pdf_download_path: string | null;
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
