import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import {
  listPriceHistoryQuerySchema,
  priceHistoryIdParamSchema,
} from './price-history.schema';
import { PriceHistoryService } from './price-history.service';
import type { PaginatedPriceHistoryResponse } from './price-history.types';

export function createPriceHistoryController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedPriceHistoryResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listPriceHistoryQuerySchema.parse(request.query);
        const service = new PriceHistoryService();
        const result = await service.listPriceHistory(
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

    getById: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = priceHistoryIdParamSchema.parse(request.params);
        const service = new PriceHistoryService();
        const data = await service.getPriceHistory(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid price history ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
