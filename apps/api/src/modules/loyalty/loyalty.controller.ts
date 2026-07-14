import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  listLoyaltyTransactionsQuerySchema,
  partyLoyaltyParamSchema,
  updateLoyaltyRulesBodySchema,
} from './loyalty.schema';
import { LoyaltyService } from './loyalty.service';

export function createLoyaltyController() {
  const service = new LoyaltyService();

  return {
    getPartyBalance: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyLoyaltyParamSchema.parse(request.params);
        const data = await service.getPartyBalance(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid party ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    listPartyTransactions: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyLoyaltyParamSchema.parse(request.params);
        const query = listLoyaltyTransactionsQuerySchema.parse(request.query);
        const result = await service.listPartyTransactions(
          businessId,
          accountId,
          id,
          query,
        );
        return sendPaginated(reply, result.data, result.meta);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}

export function createLoyaltyRulesController() {
  const service = new LoyaltyService();

  return {
    getRules: async (request: FastifyRequest, reply: FastifyReply) => {
      const { accountId, businessId } = requireAuthContext(request);
      const data = await service.getRules(businessId, accountId);
      return sendData(reply, data);
    },

    updateRules: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const body = updateLoyaltyRulesBodySchema.parse(request.body);
        const data = await service.updateRules(
          businessId,
          accountId,
          userId,
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
