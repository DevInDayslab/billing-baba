import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  createLoanAccountBodySchema,
  listLoanAccountsQuerySchema,
  loanAccountIdParamSchema,
  updateLoanAccountBodySchema,
} from './loan-account.schema';
import { LoanAccountService } from './loan-account.service';

export function createLoanAccountController() {
  const service = new LoanAccountService();

  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listLoanAccountsQuerySchema.parse(request.query);
        const result = await service.listLoanAccounts(
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
        const body = createLoanAccountBodySchema.parse(request.body);
        const data = await service.createLoanAccount(
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
        const { id } = loanAccountIdParamSchema.parse(request.params);
        const data = await service.getLoanAccount(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid loan account ID',
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
        const { id } = loanAccountIdParamSchema.parse(request.params);
        const body = updateLoanAccountBodySchema.parse(request.body);
        const data = await service.updateLoanAccount(
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
        const { id } = loanAccountIdParamSchema.parse(request.params);
        await service.deleteLoanAccount(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid loan account ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
