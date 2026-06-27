export type ApiSuccessResponse<T> = {
  success: true;
  data: T;
};

export type ApiErrorResponse = {
  success: false;
  message: string;
  code: string;
  errors: Record<string, string[]> | null;
  requestId: string;
};

export type DatabaseHealthStatus =
  | 'connected'
  | 'disconnected'
  | 'not_configured';
