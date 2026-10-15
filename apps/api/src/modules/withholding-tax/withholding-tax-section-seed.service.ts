import type { Database } from '../../db/client';
import { PRELOADED_WITHHOLDING_SECTIONS } from './withholding-tax-section.constants';
import { WithholdingTaxSectionRepository } from './withholding-tax-section.repository';

export async function seedWithholdingTaxSections(
  db: Database,
  businessId: string,
  createdBy?: string | null,
): Promise<void> {
  const repository = new WithholdingTaxSectionRepository(db);
  const existing = await repository.listActive(businessId);
  if (existing.length > 0) return;

  await repository.insertMany(
    PRELOADED_WITHHOLDING_SECTIONS.map((section) => ({
      businessId,
      kind: section.kind,
      code: section.code,
      description: section.description,
      rate: section.rate,
      applicableOn: section.applicableOn,
      isActive: true,
      isPreloaded: true,
      createdBy: createdBy ?? null,
      updatedBy: createdBy ?? null,
    })),
  );
}
