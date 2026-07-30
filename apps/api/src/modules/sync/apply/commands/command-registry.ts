import { finalizeCreditNoteHandler } from './finalize-credit-note.handler';
import { finalizeDebitNoteHandler } from './finalize-debit-note.handler';
import { finalizePurchaseHandler } from './finalize-purchase.handler';
import { finalizeSaleHandler } from './finalize-sale.handler';
import { stockAdjustmentHandler } from './stock-adjustment.handler';
import type { CommandHandler } from './command.types';

export const SUPPORTED_SYNC_COMMAND_NAMES = [
  'finalize_sale',
  'finalize_purchase',
  'finalize_credit_note',
  'finalize_debit_note',
  'stock_adjustment',
] as const;

export type SupportedSyncCommandName =
  (typeof SUPPORTED_SYNC_COMMAND_NAMES)[number];

const COMMAND_HANDLERS: Record<SupportedSyncCommandName, CommandHandler> = {
  finalize_sale: finalizeSaleHandler,
  finalize_purchase: finalizePurchaseHandler,
  finalize_credit_note: finalizeCreditNoteHandler,
  finalize_debit_note: finalizeDebitNoteHandler,
  stock_adjustment: stockAdjustmentHandler,
};

export function isSupportedSyncCommand(
  command: string,
): command is SupportedSyncCommandName {
  return command in COMMAND_HANDLERS;
}

export function getCommandHandler(command: string): CommandHandler | undefined {
  if (!isSupportedSyncCommand(command)) return undefined;
  return COMMAND_HANDLERS[command];
}
