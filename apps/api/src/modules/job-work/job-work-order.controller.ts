import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  createJobWorkOrderBodySchema,
  jobWorkOrderIdParamSchema,
  listJobWorkOrdersQuerySchema,
  updateJobWorkOrderBodySchema,
} from './job-work-order.schema';
import { JobWorkOrderService } from './job-work-order.service';

export function createJobWorkOrderController() {
  const service = new JobWorkOrderService();

  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listJobWorkOrdersQuerySchema.parse(request.query);
        const result = await service.list(businessId, accountId, query);
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
        const body = createJobWorkOrderBodySchema.parse(request.body);
        const data = await service.create(businessId, accountId, userId, body);
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
        const { id } = jobWorkOrderIdParamSchema.parse(request.params);
        const data = await service.getById(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid job work order ID',
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
        const { id } = jobWorkOrderIdParamSchema.parse(request.params);
        const body = updateJobWorkOrderBodySchema.parse(request.body);
        const data = await service.update(
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
        const { id } = jobWorkOrderIdParamSchema.parse(request.params);
        await service.delete(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid job work order ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
