import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import {
  itemBomItemIdParamSchema,
  replaceItemBomBodySchema,
} from './item-bom.schema';
import { ItemBomService } from './item-bom.service';

export function createItemBomController() {
  return {
    get: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { itemId } = itemBomItemIdParamSchema.parse(request.params);
        const service = new ItemBomService();
        const data = await service.getBom(businessId, accountId, itemId);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    replace: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { itemId } = itemBomItemIdParamSchema.parse(request.params);
        const body = replaceItemBomBodySchema.parse(request.body);
        const service = new ItemBomService();
        const data = await service.replaceBom(
          businessId,
          accountId,
          userId,
          itemId,
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
  };
}
