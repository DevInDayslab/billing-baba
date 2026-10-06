import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import type { GatewayWebhookPayload } from '../../shared/payments';
import {
  createGatewayOrderBodySchema,
  gatewayIntentIdParamSchema,
  verifyGatewayPaymentBodySchema,
} from './payment-gateway.schema';
import { PaymentGatewayService } from './payment-gateway.service';

type RequestWithRawBody = FastifyRequest & { rawBody?: Buffer };

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

function requireAuthContext(request: FastifyRequest): {
  businessId: string;
  accountId: string;
  userId?: string;
} {
  const businessId = request.businessId;
  const accountId = request.accountId;
  if (!businessId || !accountId) {
    throw new AppError('UNAUTHORIZED', 'Business not found in token', 401);
  }
  return { businessId, accountId, userId: request.userId };
}

function readIdempotencyKey(request: FastifyRequest): string | undefined {
  const key = request.headers['idempotency-key'];
  return typeof key === 'string' && key.trim().length > 0
    ? key.trim()
    : undefined;
}

export function createPaymentGatewayController(config: AppConfig) {
  const service = new PaymentGatewayService(config);

  return {
    createOrder: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, accountId, userId } = requireAuthContext(request);
        const body = createGatewayOrderBodySchema.parse(request.body);
        const result = await service.createOrder(
          {
            businessId,
            accountId,
            userId,
            idempotencyKey: readIdempotencyKey(request),
            intentType: body.intent_type,
            partyId: body.party_id,
            amount: body.amount,
            discountAmount: body.discount_amount,
            notes: body.notes,
            shortPaymentHandling: body.short_payment_handling,
            shortfallAmount: body.shortfall_amount,
            allocations: body.allocations,
            referenceNumber: body.reference_number,
            invoiceNumber: body.invoice_number,
          },
          request.log,
        );
        return sendData(reply, result, 201);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    verify: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, accountId, userId } = requireAuthContext(request);
        const body = verifyGatewayPaymentBodySchema.parse(request.body);
        const result = await service.verifyPayment(
          {
            businessId,
            accountId,
            userId,
            intentId: body.intent_id,
            razorpayOrderId: body.order_id,
            razorpayPaymentId: body.payment_id,
            razorpaySignature: body.signature,
          },
          request.log,
        );
        return sendData(reply, result);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getStatus: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, accountId } = requireAuthContext(request);
        const { id } = gatewayIntentIdParamSchema.parse(request.params);
        const result = await service.getStatus(businessId, accountId, id);
        return sendData(reply, result);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid intent ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    markCheckoutOpen: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId } = requireAuthContext(request);
      const { id } = gatewayIntentIdParamSchema.parse(request.params);
      await service.markCheckoutOpen(id, businessId);
      return sendData(reply, { ok: true });
    },

    webhook: async (request: FastifyRequest, reply: FastifyReply) => {
      const signature = request.headers['x-razorpay-signature'];
      const rawBody =
        (request as RequestWithRawBody).rawBody ??
        Buffer.from(JSON.stringify(request.body ?? {}));
      const payload = JSON.parse(
        rawBody.toString('utf8'),
      ) as GatewayWebhookPayload;
      const result = await service.handleWebhook(
        rawBody,
        typeof signature === 'string' ? signature : undefined,
        payload,
        request.log,
      );
      return sendData(reply, result);
    },
  };
}
