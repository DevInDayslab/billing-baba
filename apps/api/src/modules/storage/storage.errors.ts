import { AppError } from '../../shared/errors/app-error';

export class StorageConfigurationError extends AppError {
  constructor(
    message: string,
    code:
      | 'STORAGE_NOT_CONFIGURED'
      | 'STORAGE_CONFIG_INVALID' = 'STORAGE_NOT_CONFIGURED',
  ) {
    super(code, message, code === 'STORAGE_NOT_CONFIGURED' ? 503 : 500);
    this.name = 'StorageConfigurationError';
  }
}

export class StorageValidationError extends AppError {
  constructor(message: string, errors: Record<string, string[]> | null = null) {
    super('STORAGE_VALIDATION_ERROR', message, 400, errors);
    this.name = 'StorageValidationError';
  }
}

export class StorageNotFoundError extends AppError {
  constructor(message = 'Storage asset not found') {
    super('STORAGE_NOT_FOUND', message, 404);
    this.name = 'StorageNotFoundError';
  }
}

export class StoragePermissionError extends AppError {
  constructor(message = 'Not allowed to access this storage asset') {
    super('STORAGE_FORBIDDEN', message, 403);
    this.name = 'StoragePermissionError';
  }
}

export class StorageUploadFailedError extends AppError {
  constructor(message: string, statusCode = 400) {
    super('STORAGE_UPLOAD_FAILED', message, statusCode);
    this.name = 'StorageUploadFailedError';
  }
}
