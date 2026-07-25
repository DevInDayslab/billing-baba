import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/pos/application/pos_session_service.dart';
import 'package:billing_baba/features/pos/data/pos_local_data_source.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_sale_service.g.dart';

@Riverpod(keepAlive: true)
Future<PosSaleService> posSaleService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final sessionService = await ref.watch(posSessionServiceProvider.future);
  final localDataSource = PosLocalDataSource(ref.watch(appDatabaseProvider));
  return PosSaleService(
    remote: SalesRemoteDataSource(api.dio),
    sessionService: sessionService,
    localDataSource: localDataSource,
  );
}

class PosSaleService {
  PosSaleService({
    required this._remote,
    required this._sessionService,
    required this._localDataSource,
  });

  final SalesRemoteDataSource _remote;
  final PosSessionService _sessionService;
  final PosLocalDataSource _localDataSource;

  Future<PosSale> completeSale({
    required String businessId,
    required List<CartItem> items,
    required List<PaymentEntry> payments,
    String? partyId,
    String? notes,
    String? customerName,
  }) async {
    if (items.isEmpty) {
      throw const PosRepositoryException(message: 'Cart is empty');
    }

    try {
      final session = await _sessionService.getOrOpenSession();

      final docDto = await _remote.createDocument(
        CreateSalesDocumentRequest(
          documentType: SalesDocumentType.pos.apiValue,
          documentSeries: SalesConstants.posSeries,
          partyId: partyId ?? PosConstants.walkInPartyId,
          posSessionId: session.id,
          notes: notes,
        ),
      );

      final lineDtos = <SalesDocumentLineDto>[];
      for (var i = 0; i < items.length; i++) {
        final cartItem = items[i];
        final lineDto = await _remote.addLine(
          docDto.id,
          CreateSalesLineRequest(
            itemId: cartItem.item.id,
            quantity: cartItem.quantity.toString(),
            unit: cartItem.item.unit,
            unitPrice: cartItem.item.price.toStringAsFixed(4),
            discountAmount: cartItem.discountAmount.toStringAsFixed(4),
            sortOrder: i,
          ),
        );
        lineDtos.add(lineDto);
      }

      await _remote.finalizeDocument(docDto.id);
      final finalizedDto = await _remote.getDocument(docDto.id);

      final paymentPartyId = partyId ?? PosConstants.walkInPartyId;
      final resolvedPayments = _resolvePayments(payments, items, finalizedDto);

      final totalAmount = double.tryParse(finalizedDto.totalAmount) ?? 0;
      var remaining = totalAmount;

      for (var i = 0; i < resolvedPayments.length; i++) {
        final payment = resolvedPayments[i];
        final isLast = i == resolvedPayments.length - 1;
        final allocatedAmount = isLast
            ? double.parse(remaining.toStringAsFixed(2))
            : double.parse(payment.amount.toStringAsFixed(2));
        remaining = double.parse(
          (remaining - allocatedAmount).toStringAsFixed(2),
        );

        await _remote.createPayment(
          CreatePaymentRequest(
            partyId: paymentPartyId,
            direction: 'received',
            amount: payment.amount.toStringAsFixed(2),
            paymentMode: _paymentModeToApi(payment.mode),
            allocations: [
              PaymentAllocationRequest(
                salesDocumentId: finalizedDto.id,
                allocatedAmount: allocatedAmount.toStringAsFixed(2),
              ),
            ],
          ),
        );
      }

      await _localDataSource.saveSale(
        businessId: businessId,
        dto: finalizedDto,
        items: items,
        lineDtos: lineDtos,
        payments: resolvedPayments,
      );

      return _mapToPosSale(
        finalizedDto: finalizedDto,
        items: items,
        lineDtos: lineDtos,
        payments: resolvedPayments,
        partyId: partyId,
        customerName: customerName,
        notes: notes,
      );
    } on DioException catch (error) {
      throw _mapError(error);
    } on SalesException catch (error) {
      throw _mapSalesException(error);
    }
  }

  List<PaymentEntry> _resolvePayments(
    List<PaymentEntry> payments,
    List<CartItem> items,
    SalesDocumentDto? finalizedDto,
  ) {
    if (payments.isNotEmpty) {
      return payments;
    }

    final amount = finalizedDto != null
        ? (double.tryParse(finalizedDto.totalAmount) ?? 0)
        : items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return [PaymentEntry(mode: PaymentMode.cash, amount: amount)];
  }

  PosSale _mapToPosSale({
    required SalesDocumentDto finalizedDto,
    required List<CartItem> items,
    required List<SalesDocumentLineDto> lineDtos,
    required List<PaymentEntry> payments,
    String? partyId,
    String? customerName,
    String? notes,
  }) {
    final totalAmount = double.tryParse(finalizedDto.subtotal) ?? 0;
    final taxAmount = double.tryParse(finalizedDto.taxAmount) ?? 0;
    final finalAmount = double.tryParse(finalizedDto.totalAmount) ?? 0;
    final completedAt =
        DateTime.tryParse(finalizedDto.createdAt) ?? DateTime.now();

    final saleItems = <PosSaleLineItem>[];
    for (var i = 0; i < items.length; i++) {
      final cartItem = items[i];
      final lineDto = i < lineDtos.length ? lineDtos[i] : null;
      saleItems.add(
        PosSaleLineItem(
          name: cartItem.item.name,
          quantity: cartItem.quantity,
          lineTotal: lineDto != null
              ? (double.tryParse(lineDto.lineTotal) ?? cartItem.lineTotal)
              : cartItem.lineTotal,
          itemId: cartItem.item.id,
          unit: cartItem.item.unit,
          unitPrice: cartItem.item.price,
          cgstAmount: double.tryParse(lineDto?.cgstAmount ?? '0'),
          sgstAmount: double.tryParse(lineDto?.sgstAmount ?? '0'),
          igstAmount: double.tryParse(lineDto?.igstAmount ?? '0'),
        ),
      );
    }

    return PosSale(
      id: finalizedDto.id,
      docNumber: finalizedDto.documentNumber ?? finalizedDto.id,
      partyId: partyId,
      customerName: customerName,
      items: saleItems,
      payments: payments,
      paymentMethod: payments.map((p) => _paymentModeToApi(p.mode)).join(','),
      totalAmount: totalAmount,
      taxAmount: taxAmount,
      finalAmount: finalAmount,
      completedAt: completedAt,
      notes: notes,
      itemCount: items.fold<int>(0, (sum, item) => sum + item.quantity),
    );
  }

  String _paymentModeToApi(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => 'cash',
    PaymentMode.upi => 'upi',
    PaymentMode.card => 'card',
    PaymentMode.bank => 'bank_transfer',
  };

  PosRepositoryException _mapError(DioException error) {
    final salesError = mapSalesError(error);
    return PosRepositoryException(
      message: _friendlyMessage(salesError.message, error.response?.statusCode),
      statusCode: error.response?.statusCode,
    );
  }

  PosRepositoryException _mapSalesException(SalesException error) {
    return PosRepositoryException(message: error.message);
  }

  String _friendlyMessage(String message, int? statusCode) {
    final normalized = message.toLowerCase();
    if (statusCode == 422 &&
        (normalized.contains('insufficient stock') ||
            normalized.contains('insufficient_stock'))) {
      return 'Item out of stock. Please check quantities.';
    }
    if (statusCode == 409) {
      return 'This sale could not be completed. Please try again.';
    }
    if (statusCode == 400) {
      return 'Validation error: $message';
    }
    if (statusCode == 500) {
      return 'Server error. Please try again.';
    }
    if (statusCode == null && normalized.contains('connection')) {
      return 'No connection. Check your internet and try again.';
    }
    return message;
  }
}
