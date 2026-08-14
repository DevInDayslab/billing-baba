import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  hiddenLedgerEntryIdParamSchema,
  hiddenLedgerPartyIdParamSchema,
  listHiddenLedgerEntriesQuerySchema,
  listHiddenLedgerRecoveriesQuerySchema,
  recoverFromSaleBodySchema,
} from './hidden-ledger.schema';
import { HiddenLedgerService } from './hidden-ledger.service';

export function createHiddenLedgerController() {
  const service = new HiddenLedgerService();

  return {
    listEntries: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listHiddenLedgerEntriesQuerySchema.parse(request.query);
        const result = await service.listEntries(
          businessId,
          accountId,
          request.role,
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

    getEntry: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = hiddenLedgerEntryIdParamSchema.parse(request.params);
        const data = await service.getEntry(
          businessId,
          accountId,
          request.role,
          id,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid entry ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    listRecoveries: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = hiddenLedgerEntryIdParamSchema.parse(request.params);
        const query = listHiddenLedgerRecoveriesQuerySchema.parse(
          request.query,
        );
        const result = await service.listRecoveries(
          businessId,
          accountId,
          request.role,
          id,
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

    getPartySummary: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { partyId } = hiddenLedgerPartyIdParamSchema.parse(
          request.params,
        );
        const data = await service.getPartySummary(
          businessId,
          accountId,
          request.role,
          partyId,
        );
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

    recoverFromSale: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { partyId } = hiddenLedgerPartyIdParamSchema.parse(
          request.params,
        );
        const body = recoverFromSaleBodySchema.parse(request.body);
        const data = await service.recordSaleRecovery({
          businessId,
          accountId,
          role: request.role,
          partyId,
          saleId: body.sale_id,
          recoveryAmount: body.amount,
          userId,
        });
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
  };
}
