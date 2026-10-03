import { and, eq } from 'drizzle-orm';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { businesses, parties, payments } from '../../db/schema';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { normalizeIndianMobile } from '../../shared/utils/phone-number';
import { GeneratedDocumentService } from '../generated-documents/generated-document.service';
import { NotificationMediaService } from '../notifications/notification-media.service';
import { getSharedNotificationService } from '../notifications/notification-service.factory';

const paymentIdParamSchema = z.object({
  id: z.string().uuid(),
});

export function createPaymentNotifyHandler(config: AppConfig) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const accountId = request.accountId;
    const businessId = request.businessId;
    if (!accountId || !businessId) {
      throw new AppError('UNAUTHORIZED', 'Business context required', 401);
    }

    const { id: paymentId } = paymentIdParamSchema.parse(request.params);
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }

    const [payment] = await db
      .select()
      .from(payments)
      .where(
        and(
          eq(payments.id, paymentId),
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
        ),
      )
      .limit(1);

    if (!payment) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }

    if (payment.direction !== 'received') {
      throw new AppError(
        'INVALID_PAYMENT_DIRECTION',
        'Only received payments can send a payment-received notification',
        400,
      );
    }

    const [party] = await db
      .select({
        name: parties.name,
        mobile: parties.mobile,
      })
      .from(parties)
      .where(
        and(
          eq(parties.id, payment.partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    if (!party.mobile) {
      throw new AppError(
        'PHONE_REQUIRED',
        'Customer phone number is required',
        400,
      );
    }

    const phoneResult = normalizeIndianMobile(party.mobile);
    if (!phoneResult.ok) {
      throw new AppError('INVALID_PHONE', phoneResult.error.message, 400);
    }

    const [company] = await db
      .select({ name: businesses.name })
      .from(businesses)
      .where(
        and(eq(businesses.id, businessId), eq(businesses.isDeleted, false)),
      )
      .limit(1);

    if (!company) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    const generatedDocuments = new GeneratedDocumentService({ config });
    const mediaService = new NotificationMediaService({ config });

    try {
      await generatedDocuments.ensure(businessId, accountId, {
        documentKind: 'receipt_pdf',
        sourceType: 'payment',
        sourceId: paymentId,
      });
    } catch (error) {
      const message =
        error instanceof AppError
          ? error.message
          : 'Failed to generate receipt PDF';
      return sendData(reply, {
        notified: false,
        error: { code: 'PDF_GENERATION_FAILED', message },
      });
    }

    const receiptMediaUrl = await mediaService.resolvePaymentReceiptPdfUrl(
      businessId,
      paymentId,
    );

    if (!receiptMediaUrl) {
      return sendData(reply, {
        notified: false,
        error: {
          code: 'PDF_NOT_CACHED',
          message: 'Receipt PDF could not be prepared for WhatsApp delivery',
        },
      });
    }

    const service = getSharedNotificationService(config);
    const result = await service.sendPaymentReceived(
      { phone: phoneResult.e164 },
      {
        customerName: party.name,
        companyName: company.name,
        amount: payment.amount,
        paymentId: payment.id,
        mediaUrl: receiptMediaUrl,
      },
      {
        idempotencyKey: `payment_received:${payment.id}`,
        companyId: businessId,
      },
    );

    return sendData(reply, {
      notified: result.success,
      deduped: result.deduped === true,
      media_attached: Boolean(receiptMediaUrl && result.success),
      error: result.error
        ? { code: result.error.code, message: result.error.message }
        : undefined,
    });
  };
}
