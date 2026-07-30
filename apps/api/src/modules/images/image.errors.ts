import { AppError } from '../../shared/errors/app-error';

export class ImageValidationError extends AppError {
  constructor(message: string, fields?: Record<string, string[]>) {
    super('VALIDATION_ERROR', message, 400, fields);
    this.name = 'ImageValidationError';
  }
}

export class ImageNotFoundError extends AppError {
  constructor(message = 'Image or variant not found') {
    super('NOT_FOUND', message, 404);
    this.name = 'ImageNotFoundError';
  }
}

export class ImageProcessingError extends AppError {
  constructor(message = 'Failed to process image') {
    super('IMAGE_PROCESSING_FAILED', message, 422);
    this.name = 'ImageProcessingError';
  }
}
