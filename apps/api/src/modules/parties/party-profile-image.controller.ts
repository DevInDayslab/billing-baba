import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { brandingUploadBodySchema } from '../business/business-branding.schema';
import { toUploadIntentResponse } from '../storage/storage.mapper';
import { partyIdParamSchema } from './party.schema';
import { PartyProfileImageService } from './party-profile-image.service';

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

export function createPartyProfileImageController(config: AppConfig) {
  const service = new PartyProfileImageService({ config });

  return {
    upload: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id: partyId } = partyIdParamSchema.parse(request.params);
        const body = brandingUploadBodySchema.parse(request.body);

        if ('intent_id' in body) {
          const asset = await service.completeUpload(
            businessId,
            accountId,
            partyId,
            body.intent_id,
          );
          return sendData(reply, {
            media_asset_id: asset.media_asset_id,
            url: asset.url,
            mime_type: asset.mime_type,
            file_size: asset.file_size,
          });
        }

        const intent = await service.createUploadIntent(
          businessId,
          accountId,
          partyId,
          body.mime_type,
          body.file_size,
          body.checksum,
        );
        return sendData(reply, toUploadIntentResponse(intent), 201);
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
        const { accountId, businessId } = requireAuthContext(request);
        const { id: partyId } = partyIdParamSchema.parse(request.params);
        await service.deleteProfileImage(businessId, accountId, partyId);
        return sendData(reply, { deleted: true });
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
