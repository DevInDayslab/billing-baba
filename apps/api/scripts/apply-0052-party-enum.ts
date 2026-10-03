import 'dotenv/config';
import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import postgres from 'postgres';

const migrationPath = './drizzle/migrations/0052_document_attachment_party.sql';
const sqlContent = readFileSync(migrationPath);
const hash = createHash('sha256').update(sqlContent).digest('hex');
const createdAt = 1787800000000;

const sql = postgres(process.env.DATABASE_URL!, { max: 1 });

const existing = await sql`
  SELECT id FROM drizzle.__drizzle_migrations WHERE hash = ${hash}
`;
if (existing.length > 0) {
  console.log('Migration 0052 already recorded.');
} else {
  await sql.unsafe(sqlContent.toString());
  await sql`
    INSERT INTO drizzle.__drizzle_migrations (hash, created_at)
    VALUES (${hash}, ${createdAt})
  `;
  console.log('Applied migration 0052_document_attachment_party');
}

const labels = await sql`
  SELECT e.enumlabel
  FROM pg_enum e
  JOIN pg_type t ON e.enumtypid = t.oid
  WHERE t.typname = 'document_attachment_entity_type'
  ORDER BY e.enumsortorder
`;
console.log(
  'document_attachment_entity_type:',
  labels.map((r) => r.enumlabel),
);

await sql.end();
