import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import {
  listStockLevelsQuerySchema,
  stockLevelIdParamSchema,
} from './stock-level.schema';
import { StockLevelService } from './stock-level.service';
import type { PaginatedStockLevelsResponse } from './stock-level.types';

export function createStockLevelController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedStockLevelsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listStockLevelsQuerySchema.parse(request.query);
        const service = new StockLevelService();
        const result = await service.listStockLevels(
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
        const { id } = stockLevelIdParamSchema.parse(request.params);
        const service = new StockLevelService();
        const data = await service.getStockLevel(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid stock level ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
