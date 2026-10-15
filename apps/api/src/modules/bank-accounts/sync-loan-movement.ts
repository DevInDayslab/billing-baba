import type { Database } from '../../db/client';
import { LoanTransactionRepository } from '../loans/loan-transaction.repository';
import {
  syncLoanTransactionMovement,
  voidLoanTransactionMovement,
} from './loan-movement.helper';
import type { RowMutationInput } from '../sync/apply/sync-apply.types';

export async function afterLoanTransactionRowMutation(
  db: Database,
  input: RowMutationInput,
  operation: 'create' | 'update' | 'delete',
): Promise<void> {
  if (operation === 'delete') {
    await voidLoanTransactionMovement(db, input.businessId, input.entityId);
    return;
  }
  const repo = new LoanTransactionRepository(db);
  const txn = await repo.findById(input.businessId, input.entityId);
  if (!txn) return;
  await syncLoanTransactionMovement(db, input.businessId, txn);
}
