export type GstBusinessContext = {
  id: string;
  gstin: string | null;
  stateCode: string;
};

export type GstPartyContext = {
  id: string | null;
  name: string | null;
  gstin: string | null;
  stateCode: string | null;
};

export type GstItemContext = {
  id: string;
  name: string;
  itemType: 'product' | 'service';
  hsnCode: string | null;
};

export type GstLineModel = {
  id: string;
  itemId: string;
  quantity: string;
  unit: string;
  unitPrice: string;
  discountAmount: string;
  taxType: string;
  taxRate: string;
  cgstAmount: string;
  sgstAmount: string;
  igstAmount: string;
  cessRate: string;
  cessAmount: string;
  lineTotal: string;
  item: GstItemContext;
};

export type GstSalesDocumentModel = {
  id: string;
  documentType: string;
  status: string;
  documentNumber: string | null;
  documentSeries: string;
  documentDate: Date;
  party: GstPartyContext;
  partyStateCode: string | null;
  supplyType: string;
  subtotal: string;
  totalAmount: string;
  isGstFormal: boolean;
  originalDocumentId: string | null;
  originalDocumentNumber: string | null;
  originalDocumentDate: Date | null;
  convertedFromId: string | null;
  lines: GstLineModel[];
  isCreditNote: boolean;
};

export type GstPurchaseDocumentModel = {
  id: string;
  documentType: string;
  status: string;
  documentNumber: string | null;
  documentSeries: string;
  documentDate: Date;
  party: GstPartyContext;
  partyStateCode: string | null;
  totalAmount: string;
  isGstFormal: boolean;
  originalDocumentId: string | null;
  originalDocumentNumber: string | null;
  originalDocumentDate: Date | null;
  lines: GstLineModel[];
  isDebitNote: boolean;
};

export type GstCancelledDocStat = {
  documentSeries: string;
  count: number;
};

export type GstDataset = {
  business: GstBusinessContext;
  sales: GstSalesDocumentModel[];
  purchases: GstPurchaseDocumentModel[];
  cancelledBySeries: GstCancelledDocStat[];
};
