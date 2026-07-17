/** Shared guards for tests that require a live database and JWT secrets. */
export const canRunDbTests =
  Boolean(process.env.DATABASE_URL) && Boolean(process.env.JWT_SECRET);

export const INTEGRATION_TIMEOUT_MS = 30_000;
