import 'package:billing_baba/shared/utils/validators.dart';

enum TransactionValidationField { lineItems, party, phone, category, amount }

const String kLineItemsValidationMessage =
    'Add at least one item with name and quantity';

const String kPartyValidationMessage = 'Party is required';

const String kCategoryValidationMessage = 'Category is required';

const String kAmountValidationMessage = 'Enter a valid amount';

const String kGenericValidationMessage = 'Please fill required fields';

/// Always pass [showValidationErrors: false] when loading or duplicating forms.
const bool kResetValidationOnLoad = false;

class TransactionValidationCheck {
  const TransactionValidationCheck({
    required this.field,
    required this.isValid,
  });

  final TransactionValidationField field;
  final bool isValid;
}

/// Returns the message for the first failing validation check.
String resolveValidationMessage({
  required List<TransactionValidationCheck> checks,
  Map<TransactionValidationField, String>? fieldMessages,
}) {
  final messages = {
    TransactionValidationField.lineItems: kLineItemsValidationMessage,
    TransactionValidationField.party: kPartyValidationMessage,
    TransactionValidationField.phone:
        Validators.requiredPhone('') ?? 'Phone is required',
    TransactionValidationField.category: kCategoryValidationMessage,
    TransactionValidationField.amount: kAmountValidationMessage,
    ...?fieldMessages,
  };

  for (final check in checks) {
    if (!check.isValid) {
      return messages[check.field] ?? kGenericValidationMessage;
    }
  }
  return kGenericValidationMessage;
}

/// Resolves a phone-specific validation message when phone is invalid.
String? phoneValidationMessage(String? phone) =>
    Validators.requiredPhone(phone);

bool hasValidPhone(String? phone) => Validators.requiredPhone(phone) == null;

/// Whether at least one line item has a non-empty name (and optionally qty > 0).
bool hasValidNamedLineItems<T>({
  required Iterable<T> items,
  required String Function(T item) nameOf,
  required double Function(T item) qtyOf,
  bool requireQty = true,
}) {
  return items.any((item) {
    if (nameOf(item).trim().isEmpty) return false;
    if (requireQty && qtyOf(item) <= 0) return false;
    return true;
  });
}

/// Aligns party field error with [isValid] rules that require a linked [partyId].
bool transactionPartyHasError({
  required bool showValidationErrors,
  required String? partyId,
  String partyName = '',
  bool requireLinkedParty = true,
  bool partyRequired = true,
}) {
  if (!showValidationErrors || !partyRequired) return false;
  if (requireLinkedParty) {
    return partyId == null || partyId.isEmpty;
  }
  return partyName.trim().isEmpty;
}

bool transactionLineItemsHasError({
  required bool showValidationErrors,
  required bool hasValidLineItems,
}) {
  return showValidationErrors && !hasValidLineItems;
}

bool transactionPhoneHasError({
  required bool showValidationErrors,
  required String? phone,
}) {
  return showValidationErrors && Validators.requiredPhone(phone) != null;
}

bool transactionCategoryHasError({
  required bool showValidationErrors,
  required String category,
}) {
  return showValidationErrors && category.trim().isEmpty;
}

bool transactionAmountHasError({
  required bool showValidationErrors,
  required double amount,
}) {
  return showValidationErrors && amount <= 0;
}

/// Formats quantity for line-item inputs (drops trailing .0 for whole numbers).
String formatLineItemQty(double qty) {
  if (qty == 0) return '';
  if (qty == qty.roundToDouble()) return qty.toInt().toString();
  return qty.toString();
}

/// Builds the first validation error message for transaction save handlers.
String? buildTransactionValidationError({
  required bool hasValidLineItems,
  bool hasValidParty = true,
  bool hasValidPhone = true,
  bool hasValidCategory = true,
  bool hasValidAmount = true,
  bool requireParty = false,
  bool requirePhone = false,
  bool requireCategory = false,
  bool requireAmount = false,
  Map<TransactionValidationField, String>? fieldMessages,
}) {
  final checks = <TransactionValidationCheck>[
    TransactionValidationCheck(
      field: TransactionValidationField.lineItems,
      isValid: hasValidLineItems,
    ),
    if (requirePhone)
      TransactionValidationCheck(
        field: TransactionValidationField.phone,
        isValid: hasValidPhone,
      ),
    if (requireParty)
      TransactionValidationCheck(
        field: TransactionValidationField.party,
        isValid: hasValidParty,
      ),
    if (requireCategory)
      TransactionValidationCheck(
        field: TransactionValidationField.category,
        isValid: hasValidCategory,
      ),
    if (requireAmount)
      TransactionValidationCheck(
        field: TransactionValidationField.amount,
        isValid: hasValidAmount,
      ),
  ];

  for (final check in checks) {
    if (!check.isValid) {
      return resolveValidationMessage(
        checks: [check],
        fieldMessages: fieldMessages,
      );
    }
  }
  return null;
}
