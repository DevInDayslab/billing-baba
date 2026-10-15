import type { Database } from '../../db/client';
import { OtherIncomeRepository } from '../other-income/other-income.repository';
import {
  syncOtherIncomeMovement,
  voidOtherIncomeMovement,
} from './other-income-movement.helper';
import type { RowMutationInput } from '../sync/apply/sync-apply.types';

export async function afterOtherIncomeRowMutation(
  db: Database,
  input: RowMutationInput,
  operation: 'create' | 'update' | 'delete',
): Promise<void> {
  if (operation === 'delete') {
    await voidOtherIncomeMovement(db, input.businessId, input.entityId);
    return;
  }
  const repo = new OtherIncomeRepository(db);
  const income = await repo.findById(input.businessId, input.entityId);
  if (!income) return;
  await syncOtherIncomeMovement(db, input.businessId, income);
}
