import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  partyStatementQuerySchema,
  reportBaseQuerySchema,
  reportDateQuerySchema,
} from './reports.schema';
import { ReportsService } from './reports.service';

function handleError(error: unknown): never {
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

export function createReportsController() {
  const service = new ReportsService();

  return {
    getSaleReport: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const result = await service.getSaleReport(businessId, accountId, query);
        return reply.status(200).send(result);
      } catch (error) {
        handleError(error);
      }
    },

    getPurchaseReport: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const result = await service.getPurchaseReport(
          businessId,
          accountId,
          query,
        );
        return reply.status(200).send(result);
      } catch (error) {
        handleError(error);
      }
    },

    getStockSummary: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const result = await service.getStockSummary(
          businessId,
          accountId,
          query,
        );
        return reply.status(200).send(result);
      } catch (error) {
        handleError(error);
      }
    },

    getLowStock: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const result = await service.getLowStock(businessId, accountId, query);
        return reply.status(200).send(result);
      } catch (error) {
        handleError(error);
      }
    },

    getPartyOutstanding: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const result = await service.getPartyOutstanding(
          businessId,
          accountId,
          query,
        );
        return reply.status(200).send(result);
      } catch (error) {
        handleError(error);
      }
    },

    getPartyStatement: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = partyStatementQuerySchema.parse(request.query);
        const data = await service.getPartyStatement(
          businessId,
          accountId,
          query,
        );
        return sendData(reply, data);
      } catch (error) {
        handleError(error);
      }
    },

    getDayBook: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportDateQuerySchema.parse(request.query);
        const data = await service.getDayBook(businessId, accountId, query);
        return sendData(reply, data);
      } catch (error) {
        handleError(error);
      }
    },

    getAllTransactions: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const result = await service.getAllTransactions(
          businessId,
          accountId,
          query,
        );
        return reply.status(200).send(result);
      } catch (error) {
        handleError(error);
      }
    },

    getProfitLoss: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const data = await service.getProfitLoss(businessId, accountId, query);
        return sendData(reply, data);
      } catch (error) {
        handleError(error);
      }
    },

    getGstr1: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const data = await service.getGstr1(businessId, accountId, query);
        return sendData(reply, data);
      } catch (error) {
        handleError(error);
      }
    },

    getGstr2: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const data = await service.getGstr2(businessId, accountId, query);
        return sendData(reply, data);
      } catch (error) {
        handleError(error);
      }
    },

    getGstr3b: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = reportBaseQuerySchema.parse(request.query);
        const data = await service.getGstr3b(businessId, accountId, query);
        return sendData(reply, data);
      } catch (error) {
        handleError(error);
      }
    },
  };
}
