import type { FastifyBaseLogger } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import {
  isValid,
  normalize,
  validationError,
} from '../../shared/utils/gstin-validator';
import type { GstinVerificationResponseDto } from './gstin.dto';
import {
  GstVerifyProvider,
  type GstinVerificationProvider,
} from './gstverify.provider';

export class GstinService {
  constructor(
    private readonly config: AppConfig,
    private readonly provider: GstinVerificationProvider = new GstVerifyProvider(),
  ) {}

  async verifyGSTIN(
    gstin: string,
    logger?: FastifyBaseLogger,
  ): Promise<GstinVerificationResponseDto> {
    const normalized = normalize(gstin);
    const error = validationError(gstin);
    if (!isValid(gstin)) {
      throw new AppError(
        'VALIDATION_ERROR',
        error ?? 'Invalid GSTIN',
        400,
        { gstin: [error ?? 'Invalid GSTIN'] },
      );
    }

    const apiKey = this.config.gstverifyApiKey?.trim() ?? '';
    if (!apiKey) {
      return buildMockVerificationResponse(normalized);
    }

    const start = Date.now();
    try {
      const result = await this.provider.verify(normalized, apiKey);
      logger?.info({
        gstin: normalized,
        providerStatus: 'success',
        responseTimeMs: Date.now() - start,
        cached: result.cached,
      });
      return result;
    } catch (err) {
      if (err instanceof AppError) {
        logger?.info({
          gstin: normalized,
          providerStatus: err.statusCode,
          responseTimeMs: Date.now() - start,
        });
      }

      if (this.config.environment === 'development') {
        return buildMockVerificationResponse(normalized);
      }

      throw err;
    }
  }
}

function buildMockVerificationResponse(
  gstin: string,
): GstinVerificationResponseDto {
  return {
    success: true,
    cached: false,
    credits_remaining: 99,
    data: {
      gstin,
      legal_name: 'EXAMPLE COMPANY PRIVATE LIMITED',
      trade_name: 'Example Co',
      status: 'Active',
      constitution: 'Private Limited Company',
      taxpayer_type: 'Regular',
      registration_date: '01/07/2017',
      state: 'Maharashtra',
      pan: 'AAAAA0000A',
      address: '123 Business Park, Mumbai - 400001',
      nature_of_business: ['Supplier of Services'],
    },
  };
}
