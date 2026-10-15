import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import { AccountAdjustmentService } from './account-adjustment.service';
import { AccountBalanceService } from './account-balance.service';
import { AccountTransferService } from './account-transfer.service';
import { AccountMovementRepository } from './account-movement.repository';
import { BankAccountService } from './bank-account.service';
import { toBankAccountDto } from './bank-account.mapper';
import {
  adjustmentIdParamSchema,
  bankAccountIdParamSchema,
  createAdjustmentBodySchema,
  createBankAccountBodySchema,
  createTransferBodySchema,
  transferIdParamSchema,
  updateBankAccountBodySchema,
  updateCashOpeningBodySchema,
} from './bank-account.schema';

function requireDb() {
  const database = getDb();
  if (!database) {
    throw new AppError(
      'DATABASE_NOT_CONFIGURED',
      'Database is not configured',
      503,
    );
  }
  return database;
}

function bankService(): BankAccountService {
  return new BankAccountService(requireDb());
}

export function createBankAccountController() {
  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId } = requireAuthContext(request);
      const includeInactive =
        (request.query as { include_inactive?: string }).include_inactive ===
        'true';
      const rows = await bankService().list(businessId, includeInactive);
      return sendData(reply, rows.map(toBankAccountDto));
    },

    balances: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId } = requireAuthContext(request);
      const balances = await new AccountBalanceService(
        requireDb(),
      ).balancesForBusiness(businessId);
      return sendData(reply, balances);
    },

    create: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, userId } = requireAuthContext(request);
        const body = createBankAccountBodySchema.parse(request.body);
        const row = await bankService().createBank(businessId, userId, body);
        return sendData(reply, toBankAccountDto(row), 201);
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

    update: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, userId } = requireAuthContext(request);
        const { id } = bankAccountIdParamSchema.parse(request.params);
        const body = updateBankAccountBodySchema.parse(request.body);
        const row = await bankService().updateBank(
          businessId,
          id,
          userId,
          body,
        );
        return sendData(reply, toBankAccountDto(row));
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    updateCashOpening: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { businessId, userId } = requireAuthContext(request);
        const body = updateCashOpeningBodySchema.parse(request.body);
        const row = await bankService().updateCashOpening(
          businessId,
          userId,
          body,
        );
        return sendData(reply, toBankAccountDto(row));
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
      const { businessId, userId } = requireAuthContext(request);
      const { id } = bankAccountIdParamSchema.parse(request.params);
      const movementRepo = new AccountMovementRepository(requireDb());
      const result = await bankService().deleteOrDeactivate(
        businessId,
        id,
        userId,
        movementRepo,
      );
      return sendData(reply, result ? toBankAccountDto(result) : { deleted: true });
    },

    createTransfer: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, userId } = requireAuthContext(request);
        const body = createTransferBodySchema.parse(request.body);
        const row = await new AccountTransferService(requireDb()).create(
          businessId,
          userId,
          body,
        );
        return sendData(reply, row, 201);
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

    deleteTransfer: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId, userId } = requireAuthContext(request);
      const { id } = transferIdParamSchema.parse(request.params);
      await new AccountTransferService(requireDb()).delete(
        businessId,
        id,
        userId,
      );
      return sendData(reply, { deleted: true });
    },

    createAdjustment: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, userId } = requireAuthContext(request);
        const body = createAdjustmentBodySchema.parse(request.body);
        const row = await new AccountAdjustmentService(requireDb()).create(
          businessId,
          userId,
          body,
        );
        return sendData(reply, row, 201);
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

    deleteAdjustment: async (request: FastifyRequest, reply: FastifyReply) => {
      const { businessId, userId } = requireAuthContext(request);
      const { id } = adjustmentIdParamSchema.parse(request.params);
      await new AccountAdjustmentService(requireDb()).delete(
        businessId,
        id,
        userId,
      );
      return sendData(reply, { deleted: true });
    },
  };
}
