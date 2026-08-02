import { describe, expect, test } from 'bun:test';
import { GstinService } from '../../../src/modules/gstin/gstin.service';
import { AppError } from '../../../src/shared/errors/app-error';

describe('GstinService', () => {
  const service = new GstinService();

  test('verifyGSTIN returns mock with substituted gstin', () => {
    const result = service.verifyGSTIN('27AABCU9603R1ZN');
    expect(result.success).toBe(true);
    expect(result.cached).toBe(false);
    expect(result.credits_remaining).toBe(99);
    expect(result.data.gstin).toBe('27AABCU9603R1ZN');
    expect(result.data.legal_name).toBe('EXAMPLE COMPANY PRIVATE LIMITED');
    expect(result.data.status).toBe('Active');
  });

  test('verifyGSTIN throws for invalid gstin', () => {
    try {
      service.verifyGSTIN('INVALID');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(400);
      expect(appError.code).toBe('VALIDATION_ERROR');
    }
  });
});
