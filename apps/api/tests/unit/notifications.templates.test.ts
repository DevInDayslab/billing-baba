import { describe, expect, test } from 'bun:test';
import {
  buildPaymentReceivedNotification,
  buildPaymentReminderNotification,
  buildSaleInvoiceNotification,
  buildSyncShareInviteNotification,
  renderTemplate,
} from '../../src/notifications';

describe('notification templates', () => {
  test('renderTemplate substitutes placeholders', () => {
    expect(renderTemplate('Hello {{name}}', { name: 'Ada' })).toBe('Hello Ada');
  });

  test('sync share invite includes company and url', () => {
    const content = buildSyncShareInviteNotification({
      companyName: 'Acme Traders',
      inviteUrl: 'https://billingbaba.com/invite/ABC123',
      expiryDays: 7,
    });
    expect(content.type).toBe('sync_share_invite');
    expect(content.body).toContain('Acme Traders');
    expect(content.body).toContain('https://billingbaba.com/invite/ABC123');
    expect(content.body).toContain('7 days');
    expect(content.deepLinks.primary).toContain('/invite/');
  });

  test('payment reminder includes amount and invoice url', () => {
    const content = buildPaymentReminderNotification({
      customerName: 'Ravi',
      companyName: 'Acme',
      amount: '1500.5',
      dueDate: '20 Jul 2026',
      invoiceUrl: 'https://billingbaba.com/invoice/tok',
    });
    expect(content.body).toContain('Ravi');
    expect(content.body).toContain('₹1,500.5');
    expect(content.body).toContain('https://billingbaba.com/invoice/tok');
  });

  test('payment received and sale invoice builders', () => {
    const paid = buildPaymentReceivedNotification({
      customerName: 'Ravi',
      companyName: 'Acme',
      amount: 200,
    });
    expect(paid.type).toBe('payment_received');
    expect(paid.body).toContain('₹200');

    const sale = buildSaleInvoiceNotification({
      customerName: 'Ravi',
      invoiceNumber: 'INV-1',
      amount: 999,
      invoiceUrl: 'https://billingbaba.com/invoice/x',
    });
    expect(sale.type).toBe('sale_invoice');
    expect(sale.body).toContain('#INV-1');
    expect(sale.body).toContain('https://billingbaba.com/invoice/x');
  });
});
