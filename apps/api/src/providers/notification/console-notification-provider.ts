import { maskPhoneE164 } from '../../shared/utils/phone-number';
import type {
  NotificationProvider,
  NotificationSendResult,
  SendMediaParams,
  SendTextParams,
} from './notification-provider';

/**
 * Development / fallback provider. Logs outbound messages instead of sending.
 * Swap in via NOTIFICATION_PROVIDER=console.
 */
export class ConsoleNotificationProvider implements NotificationProvider {
  readonly name = 'console';

  constructor(
    private readonly environment:
      | 'development'
      | 'production'
      | 'test' = 'development',
  ) {}

  async sendText(params: SendTextParams): Promise<NotificationSendResult> {
    const masked = maskPhoneE164(params.to);
    console.log('==============================');
    console.log(`[${this.name}] OUTBOUND TEXT`);
    console.log(`To: ${masked}`);
    if (params.metadata) {
      console.log(`Metadata: ${JSON.stringify(params.metadata)}`);
    }
    if (this.environment !== 'production') {
      console.log('----');
      console.log(params.body);
    } else {
      console.log('(body omitted in production)');
    }
    console.log('==============================');

    return {
      success: true,
      providerMessageId: `console-${Date.now()}`,
    };
  }

  async sendMedia(params: SendMediaParams): Promise<NotificationSendResult> {
    const masked = maskPhoneE164(params.to);
    console.log('==============================');
    console.log(`[${this.name}] OUTBOUND MEDIA`);
    console.log(`To: ${masked}`);
    console.log(`Media URL: ${params.mediaUrl}`);
    if (params.body) {
      console.log('----');
      console.log(params.body);
    }
    console.log('==============================');

    return {
      success: true,
      providerMessageId: `console-media-${Date.now()}`,
    };
  }
}
