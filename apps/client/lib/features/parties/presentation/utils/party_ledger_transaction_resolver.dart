import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_repository.dart';
import 'package:billing_baba/features/purchases/models/mappers/purchase_document_mapper.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/sales/models/mappers/sales_document_mapper.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class PartyLedgerActionTarget {
  const PartyLedgerActionTarget();
}

class PartyLedgerSaleInvoiceTarget extends PartyLedgerActionTarget {
  const PartyLedgerSaleInvoiceTarget(this.invoice);

  final SaleInvoiceModel invoice;
}

class PartyLedgerSalesDocumentTarget extends PartyLedgerActionTarget {
  const PartyLedgerSalesDocumentTarget({
    required this.document,
    required this.documentType,
  });

  final SaleInvoiceModel document;
  final SalesDocumentType documentType;
}

class PartyLedgerPaymentInTarget extends PartyLedgerActionTarget {
  const PartyLedgerPaymentInTarget(this.record);

  final PaymentInModel record;
}

class PartyLedgerPaymentOutTarget extends PartyLedgerActionTarget {
  const PartyLedgerPaymentOutTarget(this.record);

  final PaymentOutModel record;
}

class PartyLedgerPurchaseBillTarget extends PartyLedgerActionTarget {
  const PartyLedgerPurchaseBillTarget(this.bill);

  final PurchaseBillModel bill;
}

class PartyLedgerPurchaseOrderTarget extends PartyLedgerActionTarget {
  const PartyLedgerPurchaseOrderTarget(this.order);

  final PurchaseOrderModel order;
}

class PartyLedgerPurchaseReturnTarget extends PartyLedgerActionTarget {
  const PartyLedgerPurchaseReturnTarget(this.item);

  final PurchaseReturnModel item;
}

abstract final class PartyLedgerTransactionResolver {
  static Future<PartyLedgerActionTarget> resolve(
    WidgetRef ref,
    PartyLedgerTransactionModel transaction,
  ) async {
    final referenceId = transaction.referenceId?.trim();
    if (referenceId == null || referenceId.isEmpty) {
      throw StateError('Transaction is missing a reference id');
    }

    final api = await ref.read(apiClientProvider.future);
    final db = ref.read(appDatabaseProvider);

    final source = transaction.source.isNotEmpty
        ? transaction.source
        : (transaction.referenceType ?? '');

    switch (source) {
      case 'sales_documents':
        return _resolveSalesDocument(
          api.dio,
          db,
          referenceId,
          transaction,
        );
      case 'purchase_documents':
        return _resolvePurchaseDocument(
          api.dio,
          db,
          referenceId,
          transaction,
        );
      case 'payments':
        return _resolvePayment(
          api.dio,
          db,
          referenceId,
          transaction,
        );
      default:
        throw StateError(
          'Unsupported transaction reference type: ${transaction.referenceType}',
        );
    }
  }

  static Future<PartyLedgerActionTarget> _resolveSalesDocument(
    Dio dio,
    AppDatabase db,
    String referenceId,
    PartyLedgerTransactionModel transaction,
  ) async {
    final repository = SalesRepository(
      remote: SalesRemoteDataSource(dio),
      local: SalesLocalDataSource(db),
    );
    final dto = await repository.getDocument(referenceId);
    final invoice = SalesDocumentMapper.toInvoiceModel(
      dto,
    );
    final documentType =
        SalesDocumentType.fromApiValue(dto.documentType) ??
        SalesDocumentType.taxInvoice;

    if (transaction.sourceType == 'sales_return' ||
        documentType == SalesDocumentType.salesReturn) {
      return PartyLedgerSalesDocumentTarget(
        document: invoice,
        documentType: SalesDocumentType.salesReturn,
      );
    }

    if (documentType == SalesDocumentType.estimate ||
        documentType == SalesDocumentType.saleOrder ||
        documentType == SalesDocumentType.deliveryChallan) {
      return PartyLedgerSalesDocumentTarget(
        document: invoice,
        documentType: documentType,
      );
    }

    return PartyLedgerSaleInvoiceTarget(invoice);
  }

  static Future<PartyLedgerActionTarget> _resolvePurchaseDocument(
    Dio dio,
    AppDatabase db,
    String referenceId,
    PartyLedgerTransactionModel transaction,
  ) async {
    final repository = PurchaseRepository(
      remote: PurchaseRemoteDataSource(dio),
      local: PurchaseLocalDataSource(db),
    );
    final dto = await repository.getDocument(referenceId);
    final documentType =
        PurchaseDocumentType.fromApiValue(dto.documentType) ??
        PurchaseDocumentType.purchaseBill;

    if (transaction.entryType == 'return' ||
        documentType == PurchaseDocumentType.purchaseReturn) {
      return PartyLedgerPurchaseReturnTarget(
        PurchaseDocumentMapper.toReturnModel(dto),
      );
    }

    if (documentType == PurchaseDocumentType.purchaseOrder) {
      return PartyLedgerPurchaseOrderTarget(
        PurchaseDocumentMapper.toOrderModel(dto),
      );
    }

    return PartyLedgerPurchaseBillTarget(
      PurchaseDocumentMapper.toBillModel(dto),
    );
  }

  static Future<PartyLedgerActionTarget> _resolvePayment(
    Dio dio,
    AppDatabase db,
    String referenceId,
    PartyLedgerTransactionModel transaction,
  ) async {
    final repository = SalesRepository(
      remote: SalesRemoteDataSource(dio),
      local: SalesLocalDataSource(db),
    );
    final dto = await repository.getPayment(referenceId);
    final direction = transaction.direction ?? dto.direction;

    if (direction == 'paid') {
      return PartyLedgerPaymentOutTarget(
        PurchaseDocumentMapper.toPaymentOutModel(dto),
      );
    }

    return PartyLedgerPaymentInTarget(
      SalesDocumentMapper.toPaymentInModel(dto),
    );
  }
}
