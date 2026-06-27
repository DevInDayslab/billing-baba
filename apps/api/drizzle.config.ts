import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    // Neon PostgreSQL — set DATABASE_URL in .env for migrate, seed, and studio.
    url: process.env.DATABASE_URL ?? '',
  },
  strict: true,
  verbose: true,
});
