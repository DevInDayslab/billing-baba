import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { SubscriptionService } from './subscription.service';

const DAY_MS = 24 * 60 * 60 * 1000;

let schedulerInterval: NodeJS.Timeout | null = null;
let startupTimeout: NodeJS.Timeout | null = null;

export function startSubscriptionScheduler(
  app: FastifyInstance,
  config: AppConfig,
): void {
  if (schedulerInterval || startupTimeout) {
    return;
  }

  const service = new SubscriptionService(config);

  const run = async () => {
    try {
      const count = await service.expireDueSubscriptions(app.log);
      if (count > 0) {
        app.log.info({ count }, 'Subscription expiry job completed');
      }
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown scheduler error';
      app.log.error({ err: message }, 'Subscription expiry job failed');
    }
  };

  startupTimeout = setTimeout(() => {
    void run();
  }, 10_000);

  schedulerInterval = setInterval(() => {
    void run();
  }, DAY_MS);

  app.log.info('Subscription expiry scheduler started');
}

export function stopSubscriptionScheduler(): void {
  if (startupTimeout) {
    clearTimeout(startupTimeout);
    startupTimeout = null;
  }
  if (schedulerInterval) {
    clearInterval(schedulerInterval);
    schedulerInterval = null;
  }
}
