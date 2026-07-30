import type { AppConfig } from '../../config/app_config';
import { NotificationService } from './notification.service';

let sharedService: NotificationService | null = null;
let sharedConfigKey: string | null = null;

function configKey(config: AppConfig): string {
  return [
    config.notificationProvider,
    config.twilioAccountSid ?? '',
    config.twilioPhoneNumber ?? '',
    String(config.notificationIdempotencyTtlHours),
  ].join('|');
}

/**
 * Returns a process-wide NotificationService so Twilio clients are not
 * recreated per HTTP request.
 */
export function getSharedNotificationService(
  config: AppConfig,
): NotificationService {
  const key = configKey(config);
  if (!sharedService || sharedConfigKey !== key) {
    sharedService = NotificationService.fromConfig(config);
    sharedConfigKey = key;
  }
  return sharedService;
}

/** Test helper — reset singleton between unit tests. */
export function resetSharedNotificationService(): void {
  sharedService = null;
  sharedConfigKey = null;
}
