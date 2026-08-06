import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { PaymentGatewayService } from './payment-gateway.service';

const RECONCILIATION_INTERVAL_MS = 5_000;

let reconciliationInterval: NodeJS.Timeout | null = null;

export function startPaymentReconciliationWorker(
  app: FastifyInstance,
  config: AppConfig,
): void {
  if (reconciliationInterval) {
    return;
  }

  const service = new PaymentGatewayService(config);

  const run = async () => {
    try {
      const count = await service.processPendingReconciliationJobs(app.log);
      if (count > 0) {
        app.log.info({ count }, 'Payment reconciliation batch processed');
      }
    } catch (error) {
      app.log.error({ err: error }, 'Payment reconciliation worker failed');
    }
  };

  reconciliationInterval = setInterval(() => {
    void run();
  }, RECONCILIATION_INTERVAL_MS);

  app.log.info('Payment reconciliation worker started');
}

export function stopPaymentReconciliationWorker(): void {
  if (reconciliationInterval) {
    clearInterval(reconciliationInterval);
    reconciliationInterval = null;
  }
}
