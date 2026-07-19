import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createBusinessBrandingController } from './business-branding.controller';

export const createBusinessBrandingRoutes = (
  config: AppConfig,
): FastifyPluginAsync => {
  const controller = createBusinessBrandingController(config);

  return async (app) => {
    app.post(
      '/logo',
      { preHandler: [authenticate, requireBusiness] },
      controller.uploadLogo,
    );
    app.delete(
      '/logo',
      { preHandler: [authenticate, requireBusiness] },
      controller.deleteLogo,
    );
    app.post(
      '/signature',
      { preHandler: [authenticate, requireBusiness] },
      controller.uploadSignature,
    );
    app.delete(
      '/signature',
      { preHandler: [authenticate, requireBusiness] },
      controller.deleteSignature,
    );
    app.post(
      '/stamp',
      { preHandler: [authenticate, requireBusiness] },
      controller.uploadStamp,
    );
    app.delete(
      '/stamp',
      { preHandler: [authenticate, requireBusiness] },
      controller.deleteStamp,
    );
    app.post(
      '/upi-qr',
      { preHandler: [authenticate, requireBusiness] },
      controller.uploadUpiQr,
    );
    app.delete(
      '/upi-qr',
      { preHandler: [authenticate, requireBusiness] },
      controller.deleteUpiQr,
    );
  };
};
