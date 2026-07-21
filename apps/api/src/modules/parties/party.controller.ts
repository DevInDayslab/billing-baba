import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  createPartyBodySchema,
  listPartiesQuerySchema,
  partyIdParamSchema,
  updatePartyBodySchema,
} from './party.schema';
import { PartyService } from './party.service';
import type { PaginatedPartiesResponse } from './party.types';
import { partyLedgerQuerySchema } from './party-ledger.schema';
import { PartyLedgerService } from './party-ledger.service';

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
  accountId: string;
  businessId: string;
  userId?: string;
} {
  const accountId = request.accountId;
  const businessId = request.businessId;
  if (!accountId || !businessId) {
    throw new AppError(
      'UNAUTHORIZED',
      'Account or business not found in token',
      401,
    );
  }

  return {
    accountId,
    businessId,
    userId: request.userId,
  };
}

export function createPartyController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedPartiesResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listPartiesQuerySchema.parse(request.query);
        const service = new PartyService();
        const result = await service.listParties(businessId, accountId, query, request.role);

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
        const body = createPartyBodySchema.parse(request.body);
        const service = new PartyService();
        const data = await service.createParty(
          businessId,
          accountId,
          userId,
          body,
          request.role,
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
        const { id } = partyIdParamSchema.parse(request.params);
        const service = new PartyService();
        const data = await service.getParty(businessId, accountId, id, request.role);
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

    getDeleteStatus: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyIdParamSchema.parse(request.params);
        const service = new PartyService();
        const data = await service.getPartyDeleteStatus(
          businessId,
          accountId,
          id,
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

    getLedger: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyIdParamSchema.parse(request.params);
        const query = partyLedgerQuerySchema.parse(request.query);
        const service = new PartyLedgerService();
        const data = await service.getPartyLedger(
          businessId,
          accountId,
          id,
          query,
        );
        return sendData(reply, data);
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

    update: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = partyIdParamSchema.parse(request.params);
        const body = updatePartyBodySchema.parse(request.body);
        const service = new PartyService();
        const data = await service.updateParty(
          businessId,
          accountId,
          userId,
          id,
          body,
          request.role,
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
        const { id } = partyIdParamSchema.parse(request.params);
        const service = new PartyService();
        const action = await service.deleteParty(
          businessId,
          accountId,
          userId,
          id,
        );
        if (action === 'deleted') {
          return reply.status(204).send();
        }
        return sendData(reply, { action });
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
  };
}
