type PostgresLikeError = {
  code?: string;
  message?: string;
  detail?: string;
  hint?: string;
  severity?: string;
  severity_local?: string;
  schema_name?: string;
  table_name?: string;
  column_name?: string;
  constraint_name?: string;
  routine?: string;
};

function asPostgresError(error: unknown): PostgresLikeError | null {
  if (!error || typeof error !== 'object') {
    return null;
  }

  const candidate = error as PostgresLikeError;
  if (
    typeof candidate.code === 'string' &&
    typeof candidate.message === 'string'
  ) {
    return candidate;
  }

  return null;
}

function formatPostgresError(error: PostgresLikeError): string {
  const parts = [
    error.severity ?? error.severity_local,
    error.code ? `code=${error.code}` : null,
    error.message,
    error.detail ? `detail=${error.detail}` : null,
    error.hint ? `hint=${error.hint}` : null,
    error.schema_name ? `schema=${error.schema_name}` : null,
    error.table_name ? `table=${error.table_name}` : null,
    error.column_name ? `column=${error.column_name}` : null,
    error.constraint_name ? `constraint=${error.constraint_name}` : null,
  ].filter(Boolean);

  return parts.join(' | ');
}

/**
 * Unwraps Drizzle/postgres-js error chains so logs include the underlying
 * PostgreSQL error (missing column, constraint violation, etc.).
 */
export function formatDatabaseError(error: unknown): string | null {
  const seen = new Set<unknown>();
  let current: unknown = error;

  while (current && typeof current === 'object' && !seen.has(current)) {
    seen.add(current);

    const postgresError = asPostgresError(current);
    if (postgresError) {
      return formatPostgresError(postgresError);
    }

    if ('cause' in current) {
      current = (current as { cause?: unknown }).cause;
      continue;
    }

    break;
  }

  return null;
}

/**
 * Builds structured log fields for unknown errors, including database details
 * when present.
 */
export function serializeErrorForLog(error: unknown): Record<string, unknown> {
  if (!(error instanceof Error)) {
    return { err: error };
  }

  const databaseError = formatDatabaseError(error);
  const cause =
    'cause' in error && error.cause !== undefined ? error.cause : undefined;

  return {
    err: error,
    ...(databaseError ? { databaseError } : {}),
    ...(cause !== undefined ? { cause } : {}),
    ...('query' in error && typeof error.query === 'string'
      ? { query: error.query }
      : {}),
    ...('params' in error ? { params: (error as { params: unknown }).params } : {}),
  };
}
