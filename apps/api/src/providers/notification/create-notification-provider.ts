import type { AppConfig } from '../../config/app_config';
import { ConsoleNotificationProvider } from './console-notification-provider';
import type { NotificationProvider } from './notification-provider';
import { TwilioWhatsAppProvider } from './twilio-whatsapp-provider';

/**
 * Selects the outbound notification provider from configuration.
 * Twilio credentials are validated at startup via loadAppConfig — no silent fallback.
 */
export function createNotificationProvider(
  config: AppConfig,
): NotificationProvider {
  if (config.notificationProvider === 'twilio') {
    const { twilioAccountSid, twilioAuthToken, twilioPhoneNumber } = config;
    if (!twilioAccountSid || !twilioAuthToken || !twilioPhoneNumber) {
      throw new Error(
        'NOTIFICATION_PROVIDER=twilio but Twilio credentials are incomplete',
      );
    }

    return new TwilioWhatsAppProvider({
      accountSid: twilioAccountSid,
      authToken: twilioAuthToken,
      phoneNumber: twilioPhoneNumber,
    });
  }

  return new ConsoleNotificationProvider(config.environment);
}
