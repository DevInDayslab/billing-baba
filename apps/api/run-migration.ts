import postgres from 'postgres';
const sql = postgres(process.env.DATABASE_URL!);
await sql`CREATE TABLE IF NOT EXISTS item_alternatives (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  business_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  deleted_at timestamp with time zone,
  is_deleted boolean DEFAULT false NOT NULL,
  created_by uuid,
  updated_by uuid,
  sync_version integer DEFAULT 1 NOT NULL,
  device_id uuid,
  item_id uuid NOT NULL,
  alternative_item_id uuid NOT NULL,
  sort_order integer DEFAULT 0 NOT NULL
)`;
await sql`ALTER TABLE item_alternatives ADD CONSTRAINT item_alternatives_business_id_fk FOREIGN KEY (business_id) REFERENCES businesses(id)`;
await sql`ALTER TABLE item_alternatives ADD CONSTRAINT item_alternatives_item_id_fk FOREIGN KEY (item_id) REFERENCES items(id)`;
await sql`ALTER TABLE item_alternatives ADD CONSTRAINT item_alternatives_alt_item_id_fk FOREIGN KEY (alternative_item_id) REFERENCES items(id)`;
await sql`CREATE UNIQUE INDEX IF NOT EXISTS uq_item_alternatives_active ON item_alternatives (business_id, item_id, alternative_item_id) WHERE is_deleted = false`;
await sql`CREATE INDEX IF NOT EXISTS idx_item_alternatives_item ON item_alternatives (business_id, item_id) WHERE is_deleted = false`;
console.log('Done!');
await sql.end();
