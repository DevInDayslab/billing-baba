import { AppError } from '../../shared/errors/app-error';
import type { SalesDocumentType } from './sales-document.types';

const ALLOWED_CONVERSIONS: Record<SalesDocumentType, SalesDocumentType[]> = {
  estimate: [
    'sale_order',
    'delivery_challan',
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
  ],
  sale_order: [
    'delivery_challan',
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
  ],
  delivery_challan: ['tax_invoice', 'bill_of_supply', 'normal_invoice'],
  normal_invoice: ['tax_invoice', 'bill_of_supply'],
  tax_invoice: [],
  bill_of_supply: [],
  pos: [],
  sales_return: [],
};

export function assertValidConversion(
  sourceType: SalesDocumentType,
  targetType: SalesDocumentType,
): void {
  const allowed = ALLOWED_CONVERSIONS[sourceType] ?? [];
  if (!allowed.includes(targetType)) {
    throw new AppError(
      'INVALID_CONVERSION',
      `Cannot convert ${sourceType} to ${targetType}`,
      422,
    );
  }
}
