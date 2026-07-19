import { describe, expect, test } from 'bun:test';
import {
  isLifecycleSalesDocument,
  resolveSalesDocumentLifecycleStatus,
} from '../../../src/shared/reporting/party-timeline/party-timeline.utils';

describe('resolveSalesDocumentLifecycleStatus', () => {
  test('maps lifecycle document statuses to display labels', () => {
    expect(
      resolveSalesDocumentLifecycleStatus('delivery_challan', 'finalized'),
    ).toBe('Open');
    expect(
      resolveSalesDocumentLifecycleStatus('delivery_challan', 'converted'),
    ).toBe('Converted');
    expect(
      resolveSalesDocumentLifecycleStatus('delivery_challan', 'cancelled'),
    ).toBe('Cancelled');
    expect(
      resolveSalesDocumentLifecycleStatus('delivery_challan', 'draft'),
    ).toBe('Draft');
  });

  test('supports estimate and sale order lifecycle documents', () => {
    expect(resolveSalesDocumentLifecycleStatus('estimate', 'finalized')).toBe(
      'Open',
    );
    expect(resolveSalesDocumentLifecycleStatus('sale_order', 'converted')).toBe(
      'Converted',
    );
  });

  test('returns null for receivable sales documents', () => {
    expect(
      resolveSalesDocumentLifecycleStatus('tax_invoice', 'finalized'),
    ).toBeNull();
    expect(
      resolveSalesDocumentLifecycleStatus('sales_return', 'finalized'),
    ).toBeNull();
  });
});

describe('isLifecycleSalesDocument', () => {
  test('identifies non-receivable lifecycle sales documents', () => {
    expect(isLifecycleSalesDocument('delivery_challan')).toBe(true);
    expect(isLifecycleSalesDocument('sale_order')).toBe(true);
    expect(isLifecycleSalesDocument('estimate')).toBe(true);
    expect(isLifecycleSalesDocument('tax_invoice')).toBe(false);
  });
});
