import { AppError } from '../../shared/errors/app-error';
import {
  isValid,
  normalize,
  validationError,
} from '../../shared/utils/gstin-validator';
import type { GstinVerificationResponseDto } from './gstin.dto';

export class GstinService {
  /**
   * Phase 2: replace `buildMockVerificationResponse` with GSTVerify API call.
   * Validators and controller stay unchanged.
   */
  verifyGSTIN(gstin: string): GstinVerificationResponseDto {
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

    return buildMockVerificationResponse(normalized);
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
