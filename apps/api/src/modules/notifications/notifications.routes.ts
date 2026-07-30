import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  isValidIndianMobile,
  maskPhoneE164,
  normalizeIndianMobile,
} from '../../shared/utils/phone-number';
import { getSharedNotificationService } from './notification-service.factory';

const testBodySchema = z.object({
  phone: z.string().trim().min(8).max(20).refine(isValidIndianMobile, {
    message: 'Phone must be a valid Indian mobile number',
  }),
});

export function createNotificationsModule(
  config: AppConfig,
): import('fastify').FastifyPluginAsync {
  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/status', { preHandler }, async (_request, reply) => {
      const connected =
        config.notificationProvider === 'console' ||
        Boolean(
          config.twilioAccountSid &&
            config.twilioAuthToken &&
            config.twilioPhoneNumber,
        );

      const senderMasked =
        config.notificationProvider === 'twilio' && config.twilioPhoneNumber
          ? maskPhoneE164(config.twilioPhoneNumber)
          : null;

      return sendData(reply, {
        provider:
          config.notificationProvider === 'twilio'
            ? 'twilio_whatsapp'
            : 'console',
        connected,
        sender_masked: senderMasked,
        website_url: config.websiteUrl,
      });
    });

    app.post(
      '/test',
      { preHandler },
      async (request: FastifyRequest, reply: FastifyReply) => {
        const accountId = request.accountId;
        const businessId = request.businessId;
        if (!accountId || !businessId) {
          throw new AppError('UNAUTHORIZED', 'Business context required', 401);
        }

        const body = testBodySchema.parse(request.body ?? {});
        const phoneResult = normalizeIndianMobile(body.phone);
        if (!phoneResult.ok) {
          throw new AppError('INVALID_PHONE', phoneResult.error.message, 400);
        }

        const service = getSharedNotificationService(config);
        const result = await service.sendTestMessage(
          { phone: phoneResult.e164 },
          {
            idempotencyKey: `test:${accountId}:${phoneResult.e164}`,
            companyId: businessId,
          },
        );

        return sendData(reply, {
          notified: result.success,
          deduped: result.deduped === true,
          error: result.error
            ? { code: result.error.code, message: result.error.message }
            : undefined,
        });
      },
    );
  };
}
