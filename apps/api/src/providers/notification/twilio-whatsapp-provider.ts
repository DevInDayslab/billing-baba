import twilio, { type Twilio } from 'twilio';
import { toWhatsAppAddress } from '../../shared/utils/phone-number';
import type {
  NotificationErrorCode,
  NotificationProvider,
  NotificationSendError,
  NotificationSendResult,
  SendTextParams,
} from './notification-provider';

export type TwilioWhatsAppConfig = {
  accountSid: string;
  authToken: string;
  /** E.164 Twilio WhatsApp-enabled number, e.g. +14155238886 */
  phoneNumber: string;
};

/** Exported for unit tests. */
export function mapTwilioError(error: unknown): NotificationSendError {
  if (error && typeof error === 'object') {
    const err = error as {
      status?: number;
      code?: number | string;
      message?: string;
    };

    const providerCode =
      err.code != null
        ? String(err.code)
        : err.status != null
          ? String(err.status)
          : undefined;
    const message =
      err.message ??
      (typeof error === 'string' ? error : 'Twilio request failed');
    const lower = message.toLowerCase();

    let code: NotificationErrorCode = 'PROVIDER_ERROR';
    let retryable = false;

    const status = err.status;
    const numericCode =
      typeof err.code === 'number'
        ? err.code
        : Number.parseInt(String(err.code ?? ''), 10);

    if (
      status === 401 ||
      status === 403 ||
      numericCode === 20003 ||
      lower.includes('authenticate')
    ) {
      code = 'AUTHENTICATION';
      retryable = false;
    } else if (
      status === 429 ||
      numericCode === 20429 ||
      lower.includes('rate limit')
    ) {
      code = 'RATE_LIMITED';
      retryable = true;
    } else if (
      numericCode === 21211 ||
      numericCode === 21614 ||
      numericCode === 21408 ||
      numericCode === 63016 ||
      numericCode === 63003 ||
      lower.includes('not a valid') ||
      lower.includes('is not a valid phone')
    ) {
      code = 'INVALID_NUMBER';
      retryable = false;
    } else if (
      lower.includes('network') ||
      lower.includes('econnreset') ||
      lower.includes('etimedout') ||
      lower.includes('fetch failed') ||
      lower.includes('socket hang up')
    ) {
      code = 'NETWORK_ERROR';
      retryable = true;
    } else if (status != null && status >= 500) {
      code = 'PROVIDER_ERROR';
      retryable = true;
    } else if (status != null && status >= 400) {
      code = 'PROVIDER_ERROR';
      retryable = false;
    }

    return { code, message, retryable, providerCode };
  }

  if (error instanceof Error) {
    const lower = error.message.toLowerCase();
    if (
      lower.includes('network') ||
      lower.includes('econnreset') ||
      lower.includes('etimedout') ||
      lower.includes('fetch failed')
    ) {
      return {
        code: 'NETWORK_ERROR',
        message: error.message,
        retryable: true,
      };
    }
    return {
      code: 'PROVIDER_ERROR',
      message: error.message,
      retryable: false,
    };
  }

  return {
    code: 'PROVIDER_ERROR',
    message: 'Unknown Twilio error',
    retryable: false,
  };
}

export class TwilioWhatsAppProvider implements NotificationProvider {
  readonly name = 'twilio_whatsapp';
  private readonly client: Twilio;
  private readonly from: string;

  constructor(config: TwilioWhatsAppConfig) {
    this.client = twilio(config.accountSid, config.authToken);
    this.from = toWhatsAppAddress(config.phoneNumber);
  }

  async sendText(params: SendTextParams): Promise<NotificationSendResult> {
    if (!params.to?.trim()) {
      return {
        success: false,
        error: {
          code: 'INVALID_NUMBER',
          message: 'Recipient phone number is required',
          retryable: false,
        },
      };
    }

    let toAddress: string;
    try {
      toAddress = toWhatsAppAddress(params.to);
    } catch (error) {
      return {
        success: false,
        error: {
          code: 'INVALID_NUMBER',
          message:
            error instanceof Error
              ? error.message
              : 'Invalid recipient phone number',
          retryable: false,
        },
      };
    }

    try {
      const message = await this.client.messages.create({
        from: this.from,
        to: toAddress,
        body: params.body,
      });

      return {
        success: true,
        providerMessageId: message.sid,
      };
    } catch (error) {
      return {
        success: false,
        error: mapTwilioError(error),
      };
    }
  }
}
