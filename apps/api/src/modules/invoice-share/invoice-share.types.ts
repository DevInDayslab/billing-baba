export type PublicInvoiceLineDto = {
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

export type PublicInvoiceLoyaltyDto = {
  earned_points: string;
  redeemed_points: string;
  points_available: string | null;
};

export type PublicInvoiceDto = {
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
    loyalty: PublicInvoiceLoyaltyDto | null;
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
  lines: PublicInvoiceLineDto[];
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
  /** @deprecated Prefer share.url — kept for website backward compatibility */
  share_url: string;
  expires_at: string | null;
  /** Public path to the cached Flutter print-layout PDF when available. */
  pdf_download_path: string | null;
};

export type InvoiceShareLinkDto = {
  token: string;
  invoice_id: string;
  share_url: string;
  expires_at: string | null;
};

export type NotifyDispatchDto = {
  notified: boolean;
  deduped?: boolean;
  share_url?: string;
  token?: string;
  media_attached?: boolean;
  error?: {
    code: string;
    message: string;
  };
};

export type PaymentQrJsonDto = {
  qr_data_url: string;
  amount: string;
  merchant: string;
  upi_id: string;
  invoice_number: string;
  upi_payload: string;
};
