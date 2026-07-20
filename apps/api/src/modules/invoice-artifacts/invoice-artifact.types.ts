export type InvoicePreviewLine = {
  itemName: string;
  quantity: string;
  unit: string;
  unitPrice: string;
  lineTotal: string;
};

export type InvoicePreviewLoyalty = {
  earnedPoints: string;
  redeemedPoints: string;
  pointsAvailable: string | null;
};

export type InvoicePreviewInput = {
  companyName: string;
  companyAddress: string | null;
  companyPhone: string | null;
  companyGstin: string | null;
  logoBuffer: Buffer | null;
  invoiceNumber: string;
  invoiceDate: string;
  customerName: string;
  customerPhone: string | null;
  lines: InvoicePreviewLine[];
  totalAmount: string;
  paidAmount: string;
  dueAmount: string;
  loyalty: InvoicePreviewLoyalty | null;
};

export type TemporaryPreviewUpload = {
  mediaAssetId: string;
  downloadUrl: string;
  expiresAt: string | null;
};

export type InvoiceShareMetadata = {
  token: string;
  shareUrl: string;
  expiresAt: string | null;
  invoiceNumber: string;
  dueAmount: string;
};

export type PaymentQrResult = {
  buffer: Buffer;
  dataUrl: string;
  upiPayload: string;
  amount: string;
  merchant: string;
  upiId: string;
  invoiceNumber: string;
};

export type PaymentQrInput = {
  upiId: string;
  companyName: string;
  dueAmount: string;
  invoiceNumber: string;
};
