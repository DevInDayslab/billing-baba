export class AppError extends Error {
  readonly code: string;
  readonly statusCode: number;
  readonly errors: Record<string, string[]> | null;

  constructor(
    code: string,
    message: string,
    statusCode = 500,
    errors: Record<string, string[]> | null = null,
  ) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.statusCode = statusCode;
    this.errors = errors;
  }
}
