import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  createOrderBodySchema,
  verifyPaymentBodySchema,
} from './subscription.schema';
import { SubscriptionService } from './subscription.service';

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
} {
  const businessId = request.businessId;
  if (!businessId) {
    throw new AppError('UNAUTHORIZED', 'Business not found in token', 401);
  }
  return { businessId };
}

export function createSubscriptionController(config: AppConfig) {
  const service = new SubscriptionService(config);

  return {
    getPlans: async (_request: FastifyRequest, reply: FastifyReply) => {
      const plans = await service.getPlans();
      return sendData(reply, plans);
    },

    getCurrent: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId } = requireAuthContext(request);
      const current = await service.getCurrent(businessId);
      return sendData(reply, current);
    },

    getHistory: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId } = requireAuthContext(request);
      const history = await service.getHistory(businessId);
      return sendData(reply, history);
    },

    refresh: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId } = requireAuthContext(request);
      const current = await service.getCurrent(businessId);
      return sendData(reply, current);
    },

    createOrder: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireAuthContext(request);
        const body = createOrderBodySchema.parse(request.body);
        const result = await service.createOrder(
          { businessId, plan: body.plan },
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
        const { businessId } = requireAuthContext(request);
        const body = verifyPaymentBodySchema.parse(request.body);
        const result = await service.verifyPayment(
          {
            businessId,
            paymentUuid: body.paymentUuid,
            razorpayOrderId: body.razorpayOrderId,
            razorpayPaymentId: body.razorpayPaymentId,
            razorpaySignature: body.razorpaySignature,
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

    webhook: async (request: FastifyRequest, reply: FastifyReply) => {
      const signature = request.headers['x-razorpay-signature'];
      const rawBody =
        (request as RequestWithRawBody).rawBody ??
        Buffer.from(JSON.stringify(request.body ?? {}));
      const payload = JSON.parse(rawBody.toString('utf8')) as {
        event?: string;
        payload?: {
          payment?: { entity?: { id?: string; order_id?: string } };
          order?: { entity?: { id?: string } };
        };
      };
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
