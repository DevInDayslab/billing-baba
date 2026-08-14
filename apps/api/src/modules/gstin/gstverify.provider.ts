import { z } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import type { GstinVerificationResponseDto } from './gstin.dto';

const GSTVERIFY_BASE_URL = 'https://gstverify.co.in/api/v1/verify';
const REQUEST_TIMEOUT_MS = 10_000;

const gstVerifyDataSchema = z.object({
  gstin: z.string(),
  legal_name: z.string(),
  trade_name: z.string(),
  status: z.string(),
  constitution: z.string(),
  taxpayer_type: z.string(),
  registration_date: z.string(),
  state: z.string(),
  pan: z.string(),
  address: z.string(),
  nature_of_business: z.array(z.string()),
});

const gstVerifyResponseSchema = z.object({
  success: z.literal(true),
  cached: z.boolean(),
  credits_remaining: z.number(),
  data: gstVerifyDataSchema,
});

export interface GstinVerificationProvider {
  verify(gstin: string, apiKey: string): Promise<GstinVerificationResponseDto>;
}

export class GstVerifyProvider implements GstinVerificationProvider {
  async verify(
    gstin: string,
    apiKey: string,
  ): Promise<GstinVerificationResponseDto> {
    let response: Response;

    try {
      response = await fetch(`${GSTVERIFY_BASE_URL}/${encodeURIComponent(gstin)}`, {
        method: 'GET',
        headers: {
          'X-API-Key': apiKey,
          accept: 'application/json',
        },
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
    } catch {
      throw new AppError(
        'GST_VERIFY_UNAVAILABLE',
        'GST verification service unavailable.',
        503,
      );
    }

    if (!response.ok) {
      throw mapProviderHttpError(response.status);
    }

    let body: unknown;
    try {
      body = await response.json();
    } catch {
      throw new AppError(
        'GST_VERIFY_UNAVAILABLE',
        'GST verification service unavailable.',
        503,
      );
    }

    const parsed = gstVerifyResponseSchema.safeParse(body);
    if (!parsed.success) {
      throw new AppError(
        'GST_VERIFY_UNAVAILABLE',
        'GST verification service unavailable.',
        503,
      );
    }

    return parsed.data;
  }
}

function mapProviderHttpError(status: number): AppError {
  if (status === 401) {
    return new AppError(
      'GST_VERIFY_AUTH_FAILED',
      'GST verification service authentication failed.',
      401,
    );
  }

  if (status === 402) {
    return new AppError(
      'GST_VERIFY_UNAVAILABLE',
      'GST verification service is temporarily unavailable.',
      503,
    );
  }

  if (status === 422) {
    return new AppError('VALIDATION_ERROR', 'Invalid GSTIN.', 400);
  }

  if (status === 429) {
    return new AppError(
      'GST_VERIFY_RATE_LIMITED',
      'Too many verification requests.',
      429,
    );
  }

  if (status >= 500) {
    return new AppError(
      'GST_VERIFY_UNAVAILABLE',
      'GST verification service unavailable.',
      503,
    );
  }

  return new AppError(
    'GST_VERIFY_UNAVAILABLE',
    'GST verification service unavailable.',
    503,
  );
}
