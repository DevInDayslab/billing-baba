import type { NotificationErrorCode } from '../../providers/notification';

const SAFE_MESSAGES: Record<NotificationErrorCode, string> = {
  INVALID_NUMBER: 'The recipient phone number is invalid',
  RATE_LIMITED: 'Messaging is temporarily rate limited. Please try again later',
  NETWORK_ERROR: 'Could not reach the messaging provider. Please try again',
  AUTHENTICATION: 'Messaging provider authentication failed',
  NOT_CONFIGURED: 'Messaging is not configured',
  UNSUPPORTED: 'This message type is not supported',
  SESSION_WINDOW:
    'WhatsApp could not deliver the message because the customer chat window expired. Ask them to send any message to your WhatsApp business number, then try again.',
  PROVIDER_ERROR: 'Could not send the message. Please try again later',
};

export function toSafeNotificationErrorMessage(
  code: NotificationErrorCode,
): string {
  return SAFE_MESSAGES[code] ?? SAFE_MESSAGES.PROVIDER_ERROR;
}

export type NotificationLogFields = {
  notification_type: string;
  provider: string;
  recipient: string;
  company_id: string | null;
  idempotency_key: string;
  status: 'success' | 'failure' | 'deduped';
  provider_message_id: string | null;
  duration_ms: number;
  error: string | null;
  timestamp: string;
};

export function logNotificationAttempt(fields: NotificationLogFields): void {
  // Structured single-line JSON for production log aggregation
  console.info(
    JSON.stringify({
      msg: 'notification_send',
      ...fields,
    }),
  );
}
