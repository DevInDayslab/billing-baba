import { AppError } from '../../shared/errors/app-error';

/** Contract error helpers — docs/11-sync-api-contract.md §13 */

export function syncValidationFailed(
  message: string,
  errors: Record<string, string[]> | null = null,
): AppError {
  return new AppError('VALIDATION_FAILED', message, 400, errors);
}

export function syncInvalidCursor(
  message = 'Invalid or corrupt sync cursor',
): AppError {
  return new AppError('INVALID_CURSOR', message, 400);
}

export function syncUnsupportedCommand(command: string): AppError {
  return new AppError(
    'UNSUPPORTED_COMMAND',
    `Unsupported sync command: ${command}`,
    400,
  );
}

export function syncBatchTooLarge(message: string): AppError {
  return new AppError('BATCH_TOO_LARGE', message, 400);
}

export function syncAuthExpired(
  message = 'Access token expired or refresh failed',
): AppError {
  return new AppError('AUTH_EXPIRED', message, 401);
}

export function syncBusinessRequired(
  message = 'JWT must include business_id for sync',
): AppError {
  return new AppError('BUSINESS_REQUIRED', message, 403);
}

export function syncBusinessChanged(
  message = 'Mutation business scope does not match JWT business_id',
): AppError {
  return new AppError('BUSINESS_CHANGED', message, 403);
}

export function syncDeviceNotRegistered(
  message = 'Device is not registered for this business',
): AppError {
  return new AppError('DEVICE_NOT_REGISTERED', message, 404);
}

export function syncBootstrapExpired(
  message = 'Bootstrap snapshot has expired',
): AppError {
  return new AppError('BOOTSTRAP_EXPIRED', message, 410);
}

export function syncProtocolMismatch(
  message = 'Unsupported X-Sync-Protocol-Version',
): AppError {
  return new AppError('PROTOCOL_MISMATCH', message, 409);
}

export function syncSchemaMismatch(
  message = 'Client schema_version is unsupported',
): AppError {
  return new AppError('SCHEMA_MISMATCH', message, 409);
}

export function syncConflict(message: string): AppError {
  return new AppError('CONFLICT', message, 409);
}

export function syncMediaChecksumMismatch(
  message = 'Uploaded bytes do not match declared checksum',
): AppError {
  return new AppError('MEDIA_CHECKSUM_MISMATCH', message, 409);
}

export function syncIdempotencyPayloadMismatch(
  message = 'command_id was reused with a different payload',
): AppError {
  return new AppError('IDEMPOTENCY_PAYLOAD_MISMATCH', message, 409);
}

export function syncRateLimited(message = 'Too many sync requests'): AppError {
  return new AppError('RATE_LIMITED', message, 429);
}

export function syncServerBusy(
  message = 'Sync service temporarily unavailable',
): AppError {
  return new AppError('SERVER_BUSY', message, 429);
}
