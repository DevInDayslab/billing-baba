import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import {
  itemSupplierItemIdParamSchema,
  replaceItemSuppliersBodySchema,
} from './item-supplier.schema';
import { ItemSupplierService } from './item-supplier.service';

export function createItemSupplierController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { itemId } = itemSupplierItemIdParamSchema.parse(request.params);
        const service = new ItemSupplierService();
        const data = await service.listSuppliers(
          businessId,
          accountId,
          itemId,
        );
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
        const { itemId } = itemSupplierItemIdParamSchema.parse(request.params);
        const body = replaceItemSuppliersBodySchema.parse(request.body);
        const service = new ItemSupplierService();
        const data = await service.replaceSuppliers(
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
