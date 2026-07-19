import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import { sourceAssetParamSchema, variantParamSchema } from './image.schema';
import { ImageService } from './image.service';

export function createImageController(config: AppConfig, service?: ImageService) {
  const imageService = service ?? new ImageService({ config });

  return {
    processSource: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { sourceAssetId } = sourceAssetParamSchema.parse(request.params);
        const data = await imageService.processSourceAsset(
          businessId,
          accountId,
          sourceAssetId,
        );
        return sendData(reply, data, 201);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid path parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    listVariants: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { sourceAssetId } = sourceAssetParamSchema.parse(request.params);
        const data = await imageService.listVariants(
          businessId,
          accountId,
          sourceAssetId,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid path parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getVariantUrl: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { sourceAssetId, variant } = variantParamSchema.parse(
          request.params,
        );
        const data = await imageService.getVariantUrl(
          businessId,
          accountId,
          sourceAssetId,
          variant,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid path parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
