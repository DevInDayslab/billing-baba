import { pgEnum } from 'drizzle-orm/pg-core';

export const userRoleEnum = pgEnum('user_role', ['owner', 'manager', 'staff']);

export const partyTypeEnum = pgEnum('party_type', [
  'customer',
  'supplier',
  'both',
]);

export const partyCategoryEnum = pgEnum('party_category', [
  'customer',
  'retailer',
  'wholesaler',
  'manufacturer',
  'custom',
]);

export const pricingTierEnum = pgEnum('pricing_tier', [
  'tier_1',
  'tier_2',
  'tier_3',
  'tier_4',
]);

export const itemTypeEnum = pgEnum('item_type', ['product', 'service']);

export const documentStatusEnum = pgEnum('document_status', [
  'draft',
  'finalized',
  'cancelled',
  'converted',
]);

export const salesDocumentTypeEnum = pgEnum('sales_document_type', [
  'estimate',
  'sale_order',
  'delivery_challan',
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
  'sales_return',
]);

export const jobWorkOrderStatusEnum = pgEnum('job_work_order_status', [
  'open',
  'closed',
  'cancelled',
]);

export const documentAttachmentEntityTypeEnum = pgEnum(
  'document_attachment_entity_type',
  [
    'sale',
    'purchase',
    'estimate',
    'sale_order',
    'purchase_order',
    'delivery_challan',
    'payment_in',
    'payment_out',
    'expense',
    'job_work',
  ],
);

export const documentAttachmentKindEnum = pgEnum('document_attachment_kind', [
  'image',
  'pdf',
  'document',
]);

export const generatedDocumentKindEnum = pgEnum('generated_document_kind', [
  'invoice_pdf',
  'estimate_pdf',
  'receipt_pdf',
  'delivery_challan_pdf',
  'purchase_pdf',
  'report_pdf',
  'excel',
  'csv',
]);

export const generatedDocumentSourceTypeEnum = pgEnum(
  'generated_document_source_type',
  ['sale_document', 'purchase_document', 'payment', 'report'],
);

export const purchaseDocumentTypeEnum = pgEnum('purchase_document_type', [
  'purchase_order',
  'purchase_bill',
  'purchase_return',
]);

export const expenseCategoryTypeEnum = pgEnum('expense_category_type', [
  'direct',
  'indirect',
]);

export const purchaseFaStatusEnum = pgEnum('purchase_fa_status', [
  'paid',
  'unpaid',
  'partially_paid',
  'overdue',
  'cancelled',
]);

export const saleFaStatusEnum = pgEnum('sale_fa_status', [
  'paid',
  'unpaid',
  'partially_paid',
  'overdue',
  'cancelled',
]);

export const taxTypeEnum = pgEnum('tax_type', [
  'cgst_sgst',
  'igst',
  'exempt',
  'none',
]);

export const paymentModeEnum = pgEnum('payment_mode', [
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
]);

export const paymentDirectionEnum = pgEnum('payment_direction', [
  'received',
  'paid',
]);

export const paymentSourceEnum = pgEnum('payment_source', [
  'manual',
  'document_finalize',
]);

export const shortPaymentHandlingEnum = pgEnum('short_payment_handling', [
  'official_balance',
  'unrecovered',
]);

export const hiddenLedgerEntryStatusEnum = pgEnum('hidden_ledger_entry_status', [
  'pending',
  'partial',
  'recovered',
]);

export const inventoryMovementTypeEnum = pgEnum('inventory_movement_type', [
  'opening',
  'purchase',
  'sale',
  'sales_return',
  'purchase_return',
  'challan',
  'adjustment',
]);

export const ledgerEntryTypeEnum = pgEnum('ledger_entry_type', [
  'sale',
  'purchase',
  'payment',
  'return',
  'expense',
  'opening',
]);

export const valuationMethodEnum = pgEnum('valuation_method', [
  'fifo',
  'average',
]);

export const attendanceStatusEnum = pgEnum('attendance_status', [
  'present',
  'late',
  'half_day',
  'overtime',
  'absent',
]);

export const todoPriorityEnum = pgEnum('todo_priority', [
  'low',
  'medium',
  'high',
]);

export const alertTypeEnum = pgEnum('alert_type', [
  'payment_overdue',
  'low_stock',
  'credit_limit',
  'price_conflict',
]);

export const onlineOrderStatusEnum = pgEnum('online_order_status', [
  'pending',
  'accepted',
  'rejected',
  'completed',
]);

export const creditLimitActionEnum = pgEnum('credit_limit_action', [
  'block',
  'warn',
]);

export const visitPurposeEnum = pgEnum('visit_purpose', [
  'purchase',
  'inquiry',
  'payment_collection',
  'casual',
]);

export const loyaltyTransactionTypeEnum = pgEnum('loyalty_transaction_type', [
  'earn',
  'redeem',
]);

export const leadSourceEnum = pgEnum('lead_source', [
  'google_ads',
  'referral',
  'website',
  'walk_in',
  'other',
]);

export const leadStatusEnum = pgEnum('lead_status', [
  'new',
  'contacted',
  'qualified',
  'converted',
  'lost',
]);

export const leadActivityTypeEnum = pgEnum('lead_activity_type', [
  'call',
  'email',
  'meeting',
  'note',
  'status_change',
]);

export const contactActivityTypeEnum = pgEnum('contact_activity_type', [
  'call',
  'email',
  'meeting',
  'note',
  'status_change',
]);

export const dealStageEnum = pgEnum('deal_stage', [
  'qualification',
  'needs_analysis',
  'value_proposition',
  'identify_decision_makers',
  'proposal_price_quote',
  'negotiation_review',
  'closed_won',
  'closed_lost',
  'closed_lost_to_competition',
]);

export const collaborationRoleEnum = pgEnum('collaboration_role', [
  'secondary_admin',
  'salesman',
  'biller',
  'biller_and_salesman',
  'accountant',
  'accountant_edit_access',
  'stock_keeper',
]);

export const companyMemberStatusEnum = pgEnum('company_member_status', [
  'active',
  'left',
  'removed',
]);

export const invitationStatusEnum = pgEnum('invitation_status', [
  'pending',
  'opened',
  'accepted',
  'rejected',
  'left',
  'expired',
  'cancelled',
]);

export const subscriptionPlanEnum = pgEnum('subscription_plan', [
  'no_plan',
  'gold',
  'platinum',
]);

export const subscriptionStatusEnum = pgEnum('subscription_status', [
  'active',
  'expired',
  'pending',
  'cancelled',
]);

export const paymentStatusEnum = pgEnum('payment_status', [
  'created',
  'paid',
  'failed',
  'refunded',
]);
