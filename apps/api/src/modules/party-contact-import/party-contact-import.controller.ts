import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  partyContactImportSessionIdParamSchema,
  partyContactImportTokenParamSchema,
  replacePartyContactImportStagingBodySchema,
} from './party-contact-import.schema';
import { PartyContactImportService } from './party-contact-import.service';

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
  return { accountId, businessId };
}

function requireAccountId(request: FastifyRequest): string {
  const accountId = request.accountId;
  if (!accountId) {
    throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
  }
  return accountId;
}

export function createPartyContactImportController(config: AppConfig) {
  const service = new PartyContactImportService(config);

  return {
    createSession: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const data = await service.createSession(businessId, accountId);
        return sendData(reply, data, 201);
      } catch (error) {
        if (error instanceof AppError) throw error;
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

    getSessionById: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyContactImportSessionIdParamSchema.parse(
          request.params,
        );
        const includeStaging =
          (request.query as { include_staging?: string }).include_staging ===
          'true';
        const data = await service.getSessionById(
          businessId,
          accountId,
          id,
          includeStaging,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof AppError) throw error;
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

    cancelSession: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyContactImportSessionIdParamSchema.parse(
          request.params,
        );
        await service.cancelSession(businessId, accountId, id);
        return sendData(reply, { cancelled: true });
      } catch (error) {
        if (error instanceof AppError) throw error;
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

    commitSession: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyContactImportSessionIdParamSchema.parse(
          request.params,
        );
        const data = await service.commitSession(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof AppError) throw error;
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

    getSessionByToken: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const accountId = requireAccountId(request);
        const { token } = partyContactImportTokenParamSchema.parse(
          request.params,
        );
        const data = await service.getSessionByToken(token, accountId);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof AppError) throw error;
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

    replaceStagingByToken: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const accountId = requireAccountId(request);
        const { token } = partyContactImportTokenParamSchema.parse(
          request.params,
        );
        const body = replacePartyContactImportStagingBodySchema.parse(
          request.body,
        );
        const data = await service.replaceStagingByToken(
          token,
          accountId,
          body,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof AppError) throw error;
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

    getPublicByToken: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { token } = partyContactImportTokenParamSchema.parse(
          request.params,
        );
        const data = await service.getPublicByToken(token);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof AppError) throw error;
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
  };
}
