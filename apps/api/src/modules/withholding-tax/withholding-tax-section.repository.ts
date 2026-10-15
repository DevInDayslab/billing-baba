import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { withholdingTaxSections } from '../../db/schema/withholding/tables';

export class WithholdingTaxSectionRepository {
  constructor(private readonly db: Database) {}

  async listActive(businessId: string) {
    return this.db
      .select()
      .from(withholdingTaxSections)
      .where(
        and(
          eq(withholdingTaxSections.businessId, businessId),
          eq(withholdingTaxSections.isDeleted, false),
          eq(withholdingTaxSections.isActive, true),
        ),
      );
  }

  async findById(businessId: string, sectionId: string) {
    const [row] = await this.db
      .select()
      .from(withholdingTaxSections)
      .where(
        and(
          eq(withholdingTaxSections.businessId, businessId),
          eq(withholdingTaxSections.id, sectionId),
          eq(withholdingTaxSections.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async insertMany(
    rows: (typeof withholdingTaxSections.$inferInsert)[],
  ): Promise<void> {
    if (rows.length === 0) return;
    await this.db.insert(withholdingTaxSections).values(rows);
  }
}
