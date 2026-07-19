enum TransactionMessageType {
  sale,
  purchase,
  saleReturn,
  purchaseReturn,
  paymentIn,
  paymentOut,
  saleOrder,
  purchaseOrder,
  estimate,
  deliveryChallan,
  cancelledInvoice,
  syncShareInvitation,
}

extension TransactionMessageTypeX on TransactionMessageType {
  String get storageKey => name;

  String get label => switch (this) {
    TransactionMessageType.sale => 'Sale',
    TransactionMessageType.purchase => 'Purchase',
    TransactionMessageType.saleReturn => 'Sale Return',
    TransactionMessageType.purchaseReturn => 'Purchase Return',
    TransactionMessageType.paymentIn => 'Payment In',
    TransactionMessageType.paymentOut => 'Payment Out',
    TransactionMessageType.saleOrder => 'Sale Order',
    TransactionMessageType.purchaseOrder => 'Purchase Order',
    TransactionMessageType.estimate => 'Estimate',
    TransactionMessageType.deliveryChallan => 'Delivery Challan',
    TransactionMessageType.cancelledInvoice => 'Cancelled Invoice',
    TransactionMessageType.syncShareInvitation => 'Sync & Share Invitation',
  };

  static TransactionMessageType fromStorageKey(String? key) {
    return TransactionMessageType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => TransactionMessageType.sale,
    );
  }
}

class MessageTemplate {
  const MessageTemplate({required this.body, required this.footer});

  final String body;
  final String footer;

  MessageTemplate copyWith({String? body, String? footer}) {
    return MessageTemplate(
      body: body ?? this.body,
      footer: footer ?? this.footer,
    );
  }
}

class TransactionMessageSettings {
  const TransactionMessageSettings({
    required this.sendToParty,
    required this.sendTransactionUpdate,
    required this.sendCopyToMyself,
    required this.includeCurrentBalance,
    required this.includeInvoiceLink,
    required this.includeFooter,
    required this.autoSend,
    required this.templates,
  });

  factory TransactionMessageSettings.defaults() {
    return TransactionMessageSettings(
      sendToParty: true,
      sendTransactionUpdate: true,
      sendCopyToMyself: false,
      includeCurrentBalance: true,
      includeInvoiceLink: true,
      includeFooter: true,
      autoSend: {
        for (final type in TransactionMessageType.values)
          type: type == TransactionMessageType.sale ||
              type == TransactionMessageType.paymentIn ||
              type == TransactionMessageType.syncShareInvitation,
      },
      templates: {
        for (final type in TransactionMessageType.values)
          type: defaultTemplateFor(type),
      },
    );
  }

  final bool sendToParty;
  final bool sendTransactionUpdate;
  final bool sendCopyToMyself;
  final bool includeCurrentBalance;
  final bool includeInvoiceLink;
  final bool includeFooter;
  final Map<TransactionMessageType, bool> autoSend;
  final Map<TransactionMessageType, MessageTemplate> templates;

  bool isAutoSendEnabled(TransactionMessageType type) =>
      autoSend[type] ?? false;

  MessageTemplate templateFor(TransactionMessageType type) =>
      templates[type] ?? defaultTemplateFor(type);

  TransactionMessageSettings copyWith({
    bool? sendToParty,
    bool? sendTransactionUpdate,
    bool? sendCopyToMyself,
    bool? includeCurrentBalance,
    bool? includeInvoiceLink,
    bool? includeFooter,
    Map<TransactionMessageType, bool>? autoSend,
    Map<TransactionMessageType, MessageTemplate>? templates,
  }) {
    return TransactionMessageSettings(
      sendToParty: sendToParty ?? this.sendToParty,
      sendTransactionUpdate:
          sendTransactionUpdate ?? this.sendTransactionUpdate,
      sendCopyToMyself: sendCopyToMyself ?? this.sendCopyToMyself,
      includeCurrentBalance:
          includeCurrentBalance ?? this.includeCurrentBalance,
      includeInvoiceLink: includeInvoiceLink ?? this.includeInvoiceLink,
      includeFooter: includeFooter ?? this.includeFooter,
      autoSend: autoSend ?? this.autoSend,
      templates: templates ?? this.templates,
    );
  }

  static MessageTemplate defaultTemplateFor(TransactionMessageType type) {
    switch (type) {
      case TransactionMessageType.sale:
        return const MessageTemplate(
          body:
              'Hello {{customer_name}},\n\nYour invoice #{{invoice_number}} has been generated.\n\nAmount:\n₹{{amount}}\n\nView Invoice:\n\n{{invoice_url}}\n\nThank you.',
          footer: '{{company_name}}',
        );
      case TransactionMessageType.paymentIn:
        return const MessageTemplate(
          body:
              'Hello {{customer_name}},\n\nWe have received your payment of ₹{{amount}}.\n\nThank you for your business.\n\n{{company_name}}',
          footer: '',
        );
      case TransactionMessageType.syncShareInvitation:
        return const MessageTemplate(
          body:
              '🏢 Billing Baba\n\n{{company_name}} has invited you to collaborate.\n\nAccept your invitation:\n\n{{invoice_url}}\n\nThis invitation expires in {{due_date}} days.',
          footer: '',
        );
      default:
        return MessageTemplate(
          body:
              'Hello {{customer_name}},\n\nUpdate from {{company_name}} regarding ${type.label.toLowerCase()}.\n\nAmount: ₹{{amount}}\n\n{{invoice_url}}',
          footer: '{{company_name}}',
        );
    }
  }
}
