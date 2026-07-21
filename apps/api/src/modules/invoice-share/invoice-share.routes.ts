import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createInvoiceShareController } from './invoice-share.controller';

/**
 * Shared controller instance so InvoiceShareService + NotificationService
 * are not triplicated across public / sales / party route plugins.
 */
let sharedController: ReturnType<typeof createInvoiceShareController> | null =
  null;

function getInvoiceShareController(config: AppConfig) {
  if (!sharedController) {
    sharedController = createInvoiceShareController(config);
  }
  return sharedController;
}

/** Public, unauthenticated invoice view by share token. */
export function createPublicInvoiceRoutes(
  config: AppConfig,
): FastifyPluginAsync {
  const controller = getInvoiceShareController(config);

  return async (app) => {
    app.get('/:token', controller.getPublicByToken);
    app.get('/:token/payment-qr', controller.getPaymentQr);
    app.get('/:token/download', controller.downloadPublicPdf);
  };
}

/** Authenticated share-link + notify endpoints nested under sales documents. */
export function createSalesInvoiceShareRoutes(
  config: AppConfig,
): FastifyPluginAsync {
  const controller = getInvoiceShareController(config);
  const preHandler = [authenticate, requireBusiness];

  return async (app) => {
    app.post('/:id/share', { preHandler }, controller.createShareLink);
    app.post('/:id/share/revoke', { preHandler }, controller.revokeShareLink);
    app.post(
      '/:id/share/regenerate',
      { preHandler },
      controller.regenerateShareLink,
    );
    app.post('/:id/notify', { preHandler }, controller.notifySaleInvoice);
  };
}

export function createPartyReminderRoutes(
  config: AppConfig,
): FastifyPluginAsync {
  const controller = getInvoiceShareController(config);
  const preHandler = [authenticate, requireBusiness];

  return async (app) => {
    app.post('/:id/reminders', { preHandler }, controller.sendPaymentReminder);
  };
}
