import type { PaginationMeta } from '../http/pagination';

export type ApiDataResponse<T> = {
  data: T;
};

export type ApiPaginatedResponse<T> = {
  data: T[];
  meta: PaginationMeta;
};

export type ApiErrorBody = {
  code: string;
  message: string;
  details?: Record<string, string[]> | null;
};

export type ApiErrorResponse = {
  error: ApiErrorBody;
  requestId: string;
};

export type DatabaseHealthStatus =
  | 'connected'
  | 'disconnected'
  | 'not_configured';
