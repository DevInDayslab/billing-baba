/**
 * Provider-agnostic outbound messaging interface.
 * Business modules must never call Twilio (or any vendor SDK) directly.
 */

export type SendTextParams = {
  /** E.164 phone number, e.g. +919876543210 */
  to: string;
  body: string;
  metadata?: Record<string, unknown>;
};

export type SendMediaParams = {
  to: string;
  body?: string;
  mediaUrl: string;
  metadata?: Record<string, unknown>;
};

export type SendTemplateParams = {
  to: string;
  templateId: string;
  variables?: Record<string, string>;
  metadata?: Record<string, unknown>;
};

export type NotificationErrorCode =
  | 'NETWORK_ERROR'
  | 'PROVIDER_ERROR'
  | 'RATE_LIMITED'
  | 'INVALID_NUMBER'
  | 'AUTHENTICATION'
  | 'NOT_CONFIGURED'
  | 'UNSUPPORTED'
  /** WhatsApp 24h customer-care window closed — need template or user reply. */
  | 'SESSION_WINDOW';

export type NotificationSendError = {
  code: NotificationErrorCode;
  message: string;
  retryable: boolean;
  providerCode?: string;
};

export type NotificationSendResult = {
  success: boolean;
  providerMessageId?: string;
  /** True when a prior successful send was reused (idempotency). */
  deduped?: boolean;
  error?: NotificationSendError;
};

export interface NotificationProvider {
  readonly name: string;

  sendText(params: SendTextParams): Promise<NotificationSendResult>;

  /** Phase 4+ — media / PDF attachments. Not implemented yet. */
  sendMedia?(params: SendMediaParams): Promise<NotificationSendResult>;

  /** Phase 4+ — provider-native templates (e.g. Twilio Content API). */
  sendTemplate?(params: SendTemplateParams): Promise<NotificationSendResult>;
}
