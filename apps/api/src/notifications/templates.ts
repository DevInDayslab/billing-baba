/**
 * All user-visible outbound notification copy lives here.
 * Do not hardcode message text in providers or business services.
 */

export const SYNC_SHARE_INVITE_TEMPLATE = `🏢 Billing Baba

{{company_name}} has invited you to collaborate.

Accept your invitation:

{{invite_url}}

This invitation expires in {{expiry_days}} days.`;

export const PAYMENT_REMINDER_TEMPLATE = `Hello {{customer_name}},

This is a friendly reminder that ₹{{amount}} is pending with {{company_name}}.

Due Date:
{{due_date}}

If you have already paid, kindly ignore this message.

View Invoice:
{{invoice_url}}

Thank you.`;

export const PAYMENT_RECEIVED_TEMPLATE = `Hello {{customer_name}},

We have received your payment of ₹{{amount}}.

Thank you for your business.

{{company_name}}`;

export const SALE_INVOICE_TEMPLATE = `Hello {{customer_name}},

Your invoice #{{invoice_number}} has been generated.

Amount:
₹{{amount}}

View Invoice:

{{invoice_url}}

Thank you.`;
