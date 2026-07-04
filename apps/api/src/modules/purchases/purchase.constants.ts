export const PURCHASE_BILL_SERIES = 'PB';
export const PURCHASE_ORDER_SERIES = 'PO';
export const PURCHASE_RETURN_SERIES = 'DN';

export const DEFAULT_SERIES_BY_TYPE = {
  purchase_bill: PURCHASE_BILL_SERIES,
  purchase_order: PURCHASE_ORDER_SERIES,
  purchase_return: PURCHASE_RETURN_SERIES,
} as const;
