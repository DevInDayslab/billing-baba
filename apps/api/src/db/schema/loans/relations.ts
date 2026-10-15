import { relations } from 'drizzle-orm';
import { bankAccounts } from '../bank-accounts/tables';
import { loanAccounts, loanTransactions } from './tables';

export const loanAccountsRelations = relations(loanAccounts, ({ one, many }) => ({
  receivedBankAccount: one(bankAccounts, {
    fields: [loanAccounts.receivedBankAccountId],
    references: [bankAccounts.id],
  }),
  transactions: many(loanTransactions),
}));

export const loanTransactionsRelations = relations(
  loanTransactions,
  ({ one }) => ({
    loanAccount: one(loanAccounts, {
      fields: [loanTransactions.loanAccountId],
      references: [loanAccounts.id],
    }),
    bankAccount: one(bankAccounts, {
      fields: [loanTransactions.bankAccountId],
      references: [bankAccounts.id],
    }),
  }),
);
