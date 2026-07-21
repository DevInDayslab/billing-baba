import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  ensureGeneratedDocumentBodySchema,
  generatedDocumentIdParamSchema,
  generatedDocumentPublicTokenParamSchema,
  lookupGeneratedDocumentQuerySchema,
  regenerateGeneratedDocumentBodySchema,
} from './generated-document.schema';
import { GeneratedDocumentService } from './generated-document.service';

export function createGeneratedDocumentController(config: AppConfig) {
  const service = new GeneratedDocumentService({ config });

  return {
    lookup: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = lookupGeneratedDocumentQuerySchema.parse(request.query);
        const data = await service.lookup(
          businessId,
          accountId,
          query.document_kind,
          query.source_type,
          query.source_id,
        );
        return sendData(reply, data);
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

    ensure: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const body = ensureGeneratedDocumentBodySchema.parse(request.body);
        const data = await service.ensure(businessId, accountId, {
          documentKind: body.document_kind,
          sourceType: body.source_type,
          sourceId: body.source_id,
          fileName: body.file_name,
          contentBase64: body.content_base64,
          forceRegenerate: body.force_regenerate,
        });
        return sendData(reply, data, data.cached ? 200 : 201);
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

    getSignedUrl: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const params = generatedDocumentIdParamSchema.parse(request.params);
        const data = await service.getSignedDownloadUrl(
          businessId,
          accountId,
          params.id,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid document ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    regenerate: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const params = generatedDocumentIdParamSchema.parse(request.params);
        const body = regenerateGeneratedDocumentBodySchema.parse(request.body);
        const data = await service.regenerate(
          businessId,
          accountId,
          params.id,
          {
            fileName: body.file_name,
            mimeType: body.mime_type,
            contentBase64: body.content_base64,
          },
        );
        return sendData(reply, data);
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

    getPublicMetadata: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const params = generatedDocumentPublicTokenParamSchema.parse(
          request.params,
        );
        const data = await service.getPublicDocument(params.token);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid token',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getPublicFile: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const params = generatedDocumentPublicTokenParamSchema.parse(
          request.params,
        );
        const url = await service.getPublicFileRedirectUrl(params.token);
        return reply.redirect(url);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid token',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
