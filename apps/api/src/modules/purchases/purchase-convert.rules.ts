import { AppError } from '../../shared/errors/app-error';
import type { PurchaseDocumentType } from './purchase-document.types';

const ALLOWED_CONVERSIONS: Record<
  PurchaseDocumentType,
  PurchaseDocumentType[]
> = {
  purchase_order: ['purchase_bill'],
  purchase_bill: ['purchase_return'],
  purchase_return: [],
};

export function assertValidConversion(
  sourceType: PurchaseDocumentType,
  targetType: PurchaseDocumentType,
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
