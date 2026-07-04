import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  allocationIdParamSchema,
  createAllocationBodySchema,
  createPaymentBodySchema,
  listPaymentsQuerySchema,
  paymentIdParamSchema,
  updatePaymentBodySchema,
} from './payment.schema';
import { PaymentService } from './payment.service';

export function createPaymentController() {
  const service = new PaymentService();

  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listPaymentsQuerySchema.parse(request.query);
        const result = await service.listPayments(
          businessId,
          accountId,
          query,
        );
        return sendPaginated(reply, result.data, result.meta);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid query parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    create: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const body = createPaymentBodySchema.parse(request.body);
        const data = await service.createPayment(
          businessId,
          accountId,
          userId,
          body,
        );
        return sendData(reply, data, 201);
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

    getById: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = paymentIdParamSchema.parse(request.params);
        const data = await service.getPayment(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid payment ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    update: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = paymentIdParamSchema.parse(request.params);
        const body = updatePaymentBodySchema.parse(request.body);
        const data = await service.updatePayment(
          businessId,
          accountId,
          userId,
          id,
          body,
        );
        return sendData(reply, data);
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

    delete: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = paymentIdParamSchema.parse(request.params);
        await service.deletePayment(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid payment ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    listAllocations: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = paymentIdParamSchema.parse(request.params);
        const data = await service.listAllocations(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid payment ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    addAllocation: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = paymentIdParamSchema.parse(request.params);
        const body = createAllocationBodySchema.parse(request.body);
        const data = await service.addAllocation(
          businessId,
          accountId,
          userId,
          id,
          body,
        );
        return sendData(reply, data, 201);
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

    deleteAllocation: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, allocationId } = allocationIdParamSchema.parse(
          request.params,
        );
        await service.deleteAllocation(
          businessId,
          accountId,
          userId,
          id,
          allocationId,
        );
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid allocation ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
