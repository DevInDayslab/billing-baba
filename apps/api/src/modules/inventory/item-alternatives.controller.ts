import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { requireAuthContext } from './inventory.controller-helpers';
import { ItemAlternativesService } from './item-alternatives.service';

const itemIdParamSchema = z.object({
  id: z.string().uuid(),
});

const alternativeItemIdParamSchema = z.object({
  id: z.string().uuid(),
  alternativeItemId: z.string().uuid(),
});

const addAlternativeBodySchema = z.object({
  alternative_item_id: z.string().uuid(),
});

const reorderAlternativesBodySchema = z.object({
  ordered_ids: z.array(z.string().uuid()),
});

export function createItemAlternativesController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemAlternativesService();
        const data = await service.listAlternatives(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof AppError) {
          throw error;
        }
        request.log.error({ err: error }, 'item-alternatives error');
        throw new AppError(
          'INTERNAL_ERROR',
          'An unexpected error occurred',
          500,
        );
      }
    },

    add: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const body = addAlternativeBodySchema.parse(request.body);
        const service = new ItemAlternativesService();
        const data = await service.addAlternative(
          businessId,
          accountId,
          userId,
          id,
          body.alternative_item_id,
        );
        return sendData(reply, data, 201);
      } catch (error) {
        if (error instanceof z.ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            Object.fromEntries(
              error.issues.map((issue) => [
                issue.path.join('.') || 'body',
                [issue.message],
              ]),
            ),
          );
        }
        if (error instanceof AppError) {
          throw error;
        }
        request.log.error({ err: error }, 'item-alternatives error');
        throw new AppError(
          'INTERNAL_ERROR',
          'An unexpected error occurred',
          500,
        );
      }
    },

    remove: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, alternativeItemId } = alternativeItemIdParamSchema.parse(
          request.params,
        );
        const service = new ItemAlternativesService();
        await service.removeAlternative(
          businessId,
          accountId,
          userId,
          id,
          alternativeItemId,
        );
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof z.ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid parameters',
            400,
            Object.fromEntries(
              error.issues.map((issue) => [
                issue.path.join('.') || 'params',
                [issue.message],
              ]),
            ),
          );
        }
        if (error instanceof AppError) {
          throw error;
        }
        request.log.error({ err: error }, 'item-alternatives error');
        throw new AppError(
          'INTERNAL_ERROR',
          'An unexpected error occurred',
          500,
        );
      }
    },

    reorder: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const body = reorderAlternativesBodySchema.parse(request.body);
        const service = new ItemAlternativesService();
        await service.reorderAlternatives(
          businessId,
          accountId,
          id,
          body.ordered_ids,
        );
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof z.ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            Object.fromEntries(
              error.issues.map((issue) => [
                issue.path.join('.') || 'body',
                [issue.message],
              ]),
            ),
          );
        }
        if (error instanceof AppError) {
          throw error;
        }
        request.log.error({ err: error }, 'item-alternatives error');
        throw new AppError(
          'INTERNAL_ERROR',
          'An unexpected error occurred',
          500,
        );
      }
    },

    recommendations: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemAlternativesService();
        const data = await service.getRecommendations(
          businessId,
          accountId,
          id,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof AppError) {
          throw error;
        }
        request.log.error({ err: error }, 'item-alternatives error');
        throw new AppError(
          'INTERNAL_ERROR',
          'An unexpected error occurred',
          500,
        );
      }
    },
  };
}
