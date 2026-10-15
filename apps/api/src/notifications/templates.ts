/**
 * All user-visible outbound notification copy lives here.
 * Do not hardcode message text in providers or business services.
 */

export const PARTY_CONTACT_IMPORT_TEMPLATE = `📇 Billing Baba

Import phone contacts as parties for {{company_name}}.

Open this link on your phone:

{{import_url}}

This link expires in {{expiry_minutes}} minutes.`;

export const SYNC_SHARE_INVITE_TEMPLATE = `🏢 Billing Baba

{{company_name}} has invited you to collaborate.

Accept your invitation:

{{invite_url}}

This invitation expires in {{expiry_days}} days.`;

export const PAYMENT_REMINDER_TEMPLATE = `Dear {{customer_name}},

Your payment of ₹{{amount}} is pending with {{company_name}}.

If you have already made the payment, kindly ignore this message.

Thank You,
{{company_name}}
{{company_phone}}`;

export const PAYMENT_RECEIVED_TEMPLATE = `Hello {{customer_name}},

We have received your payment of ₹{{amount}}.

Thank you for your business.

{{company_name}}`;

export const SALE_INVOICE_TEMPLATE = `Hello {{customer_name}},

Your invoice #{{invoice_number}} has been generated.

Amount:
₹{{amount}}

Open Full Invoice:

{{invoice_url}}

Thank you.`;
