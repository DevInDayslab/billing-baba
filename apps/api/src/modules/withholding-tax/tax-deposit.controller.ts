import type { FastifyReply, FastifyRequest } from 'fastify';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { requireAuthContext } from '../inventory/inventory.controller-helpers';
import {
  createTaxDepositBodySchema,
  listTaxDepositsQuerySchema,
  taxDepositIdParamSchema,
} from './tax-deposit.schema';
import { TaxDepositService } from './tax-deposit.service';

function service(): TaxDepositService {
  const db = getDb();
  if (!db) {
    throw new AppError(
      'DATABASE_NOT_CONFIGURED',
      'Database is not configured',
      503,
    );
  }
  return new TaxDepositService(db);
}

export function createTaxDepositController() {
  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      const query = listTaxDepositsQuerySchema.parse(request.query);
      const { businessId } = requireAuthContext(request);
      const rows = await service().list(businessId, query.kind);
      return sendData(reply, rows);
    },
    create: async (request: FastifyRequest, reply: FastifyReply) => {
      const body = createTaxDepositBodySchema.parse(request.body);
      const { businessId, userId } = requireAuthContext(request);
      const row = await service().create(businessId, userId, body);
      return sendData(reply, row, 201);
    },
    delete: async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = taxDepositIdParamSchema.parse(request.params);
      const { businessId, userId } = requireAuthContext(request);
      await service().delete(businessId, id, userId);
      return sendData(reply, { deleted: true });
    },
  };
}
