import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import { toUploadIntentResponse } from '../storage/storage.mapper';
import {
  documentAttachmentIdParamSchema,
  documentAttachmentUploadBodySchema,
  listDocumentAttachmentsQuerySchema,
  updateDocumentAttachmentBodySchema,
} from './document-attachment.schema';
import { DocumentAttachmentService } from './document-attachment.service';

export function createDocumentAttachmentController(config: AppConfig) {
  const service = new DocumentAttachmentService({ config });

  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listDocumentAttachmentsQuerySchema.parse(request.query);
        const data = await service.listAttachments(
          businessId,
          accountId,
          request.role,
          query.entity_type,
          query.entity_id,
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

    upload: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const query = listDocumentAttachmentsQuerySchema.parse(request.query);
        const body = documentAttachmentUploadBodySchema.parse(request.body);

        if ('mime_type' in body) {
          const intent = await service.createUploadIntent(
            businessId,
            accountId,
            request.role,
            query.entity_type,
            query.entity_id,
            body.mime_type,
            body.file_size,
            body.checksum,
          );
          return sendData(reply, toUploadIntentResponse(intent), 201);
        }

        const data = await service.completeUpload(
          businessId,
          accountId,
          userId,
          request.role,
          query.entity_type,
          query.entity_id,
          body.intent_id,
          {
            fileName: body.file_name,
            label: body.label,
            sortOrder: body.sort_order,
            replacesAttachmentId: body.replaces_attachment_id,
          },
        );
        return sendData(reply, data, 201);
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

    getDownloadUrl: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = documentAttachmentIdParamSchema.parse(request.params);
        const data = await service.getDownloadUrl(
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
            'Invalid attachment ID',
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
        const { id } = documentAttachmentIdParamSchema.parse(request.params);
        const body = updateDocumentAttachmentBodySchema.parse(request.body);
        const data = await service.updateMetadata(
          businessId,
          accountId,
          userId,
          request.role,
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
        const { id } = documentAttachmentIdParamSchema.parse(request.params);
        await service.deleteAttachment(
          businessId,
          accountId,
          userId,
          request.role,
          id,
        );
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid attachment ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
