import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { toUploadIntentResponse } from '../storage/storage.mapper';
import type { BrandingKind } from './business-branding.constants';
import { brandingUploadBodySchema } from './business-branding.schema';
import {
  AccountAvatarService,
  BusinessBrandingService,
} from './business-branding.service';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

function toBrandingAssetResponse(
  asset: Awaited<ReturnType<BusinessBrandingService['completeBrandingUpload']>>,
) {
  return {
    media_asset_id: asset.media_asset_id,
    url: asset.url,
    mime_type: asset.mime_type,
    file_size: asset.file_size,
  };
}

export function createBusinessBrandingController(config: AppConfig) {
  const brandingService = new BusinessBrandingService({ config });
  const avatarService = new AccountAvatarService({ config });

  const handleBrandingUpload =
    (kind: BrandingKind) =>
    async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const accountId = request.accountId;
        const businessId = request.businessId;
        if (!accountId || !businessId) {
          throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
        }

        brandingService.assertCanWriteBranding(request.role);
        const body = brandingUploadBodySchema.parse(request.body);

        if ('intent_id' in body) {
          const asset = await brandingService.completeBrandingUpload(
            businessId,
            accountId,
            kind,
            body.intent_id,
          );
          return sendData(reply, toBrandingAssetResponse(asset));
        }

        const intent = await brandingService.createBrandingUploadIntent(
          businessId,
          accountId,
          kind,
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
    };

  const handleBrandingDelete =
    (kind: BrandingKind) =>
    async (request: FastifyRequest, reply: FastifyReply) => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      brandingService.assertCanWriteBranding(request.role);
      await brandingService.deleteBranding(businessId, accountId, kind);
      return sendData(reply, { deleted: true });
    };

  return {
    uploadLogo: handleBrandingUpload('logo'),
    deleteLogo: handleBrandingDelete('logo'),
    uploadSignature: handleBrandingUpload('signature'),
    deleteSignature: handleBrandingDelete('signature'),
    uploadStamp: handleBrandingUpload('stamp'),
    deleteStamp: handleBrandingDelete('stamp'),
    uploadUpiQr: handleBrandingUpload('upi_qr'),
    deleteUpiQr: handleBrandingDelete('upi_qr'),

    uploadAvatar: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const accountId = request.accountId;
        if (!accountId) {
          throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
        }

        const body = brandingUploadBodySchema.parse(request.body);

        if ('intent_id' in body) {
          const asset = await avatarService.completeAvatarUpload(
            accountId,
            body.intent_id,
          );
          return sendData(reply, toBrandingAssetResponse(asset));
        }

        const intent = await avatarService.createAvatarUploadIntent(
          accountId,
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

    deleteAvatar: async (request: FastifyRequest, reply: FastifyReply) => {
      const accountId = request.accountId;
      if (!accountId) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      await avatarService.deleteAvatar(accountId);
      return sendData(reply, { deleted: true });
    },
  };
}
