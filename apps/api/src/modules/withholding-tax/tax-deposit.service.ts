import type { Database } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { parseMoney } from '../inventory/inventory.utils';
import { BankAccountService } from '../bank-accounts/bank-account.service';
import {
  recordTaxDepositMovement,
  voidTaxDepositMovement,
} from './tax-deposit-movement.helper';
import { TaxDepositRepository } from './tax-deposit.repository';
import { WithholdingTaxEntryRepository } from './withholding-tax-entry.repository';
import type { CreateTaxDepositBody } from './tax-deposit.schema';

export class TaxDepositService {
  private readonly deposits: TaxDepositRepository;
  private readonly entries: WithholdingTaxEntryRepository;

  constructor(private readonly db: Database) {
    this.deposits = new TaxDepositRepository(db);
    this.entries = new WithholdingTaxEntryRepository(db);
  }

  async list(businessId: string, kind?: 'tds' | 'tcs') {
    return this.deposits.list(businessId, kind);
  }

  async create(
    businessId: string,
    userId: string | undefined,
    body: CreateTaxDepositBody,
  ) {
    if (parseMoney(body.amount) <= 0) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Deposit amount must be greater than zero',
        422,
      );
    }

    return this.db.transaction(async (tx) => {
      const depositRepo = new TaxDepositRepository(
        tx as unknown as Database,
      );
      const entryRepo = new WithholdingTaxEntryRepository(
        tx as unknown as Database,
      );

      const bankService = new BankAccountService(tx as unknown as Database);
      const bankAccountId = body.bank_account_id
        ? await bankService.resolveAccountId(
            businessId,
            'bank_transfer',
            body.bank_account_id,
            userId,
          )
        : null;

      const deposit = await depositRepo.create({
        businessId,
        kind: body.kind,
        bsrCode: body.bsr_code,
        challanSerial: body.challan_serial,
        depositDate: body.deposit_date,
        amount: body.amount,
        bankAccountId,
        notes: body.notes ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      if (body.entry_ids?.length) {
        await entryRepo.markDeposited(
          businessId,
          body.entry_ids,
          deposit.id,
        );
      }

      await recordTaxDepositMovement(
        tx as unknown as Database,
        businessId,
        {
          id: deposit.id,
          amount: deposit.amount,
          depositDate: deposit.depositDate,
          challanSerial: deposit.challanSerial,
          bankAccountId: deposit.bankAccountId,
        },
        userId,
      );

      return deposit;
    });
  }

  async delete(businessId: string, depositId: string, userId?: string) {
    return this.db.transaction(async (tx) => {
      const depositRepo = new TaxDepositRepository(tx as unknown as Database);
      const existing = await depositRepo.findById(businessId, depositId);
      if (!existing) {
        throw new AppError('NOT_FOUND', 'Tax deposit not found', 404);
      }
      const deleted = await depositRepo.softDelete(
        businessId,
        depositId,
        userId,
      );
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Tax deposit not found', 404);
      }
      await voidTaxDepositMovement(
        tx as unknown as Database,
        businessId,
        depositId,
      );
    });
  }
}
