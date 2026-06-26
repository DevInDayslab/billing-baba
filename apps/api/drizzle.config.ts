import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    // Generate does not connect; migrate/push/studio require DATABASE_URL in .env
    url: process.env.DATABASE_URL ?? 'postgresql://localhost:5432/billing_baba',
  },
  strict: true,
  verbose: true,
});
