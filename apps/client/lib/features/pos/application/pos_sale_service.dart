import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/application/pos_sale_mapper.dart';
import 'package:billing_baba/features/pos/application/pos_session_service.dart';
import 'package:billing_baba/features/pos/data/pos_local_data_source.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_sale_service.g.dart';

@Riverpod(keepAlive: true)
Future<PosSaleService> posSaleService(Ref ref) async {
  final sessionService = await ref.watch(posSessionServiceProvider.future);
  final localDataSource = PosLocalDataSource(ref.watch(appDatabaseProvider));
  final commandRepository = await ref.watch(
    salesInvoiceCommandRepositoryProvider.future,
  );
  return PosSaleService(
    sessionService: sessionService,
    localDataSource: localDataSource,
    commandRepository: commandRepository,
  );
}

class PosSaleService {
  PosSaleService({
    required this._sessionService,
    required this._localDataSource,
    required this._commandRepository,
  });

  final PosSessionService _sessionService;
  final PosLocalDataSource _localDataSource;
  final SalesInvoiceCommandRepository _commandRepository;

  Future<PosSale> completeSale({
    required String businessId,
    required PosCartState cart,
    String? partyId,
    String? notes,
    String? customerName,
  }) async {
    if (cart.items.isEmpty) {
      throw const PosRepositoryException(message: 'Cart is empty');
    }

    final session = await _sessionService.getOrOpenSession();
    final draftInput = mapPosCartToDraftInput(
      cart: cart,
      posSessionId: session.id,
      partyId: partyId,
      notes: notes,
    );
    final itemNameToId = {
      for (final item in cart.items) item.item.name: item.item.id,
    };

    final draft = await _commandRepository.saveDraft(
      draftInput,
      itemNameToId: itemNameToId,
    );

    final payment = mapPosPaymentsToFinalizeCommand(
      payments: cart.payments,
      totalPayable: cart.totalPayable,
    );

    await _commandRepository.finalize(
      documentId: draft.id,
      localDocumentNumber: draft.documentNumber,
      payment: payment,
    );

    final finalizedDto =
        await _commandRepository.getDocument(draft.id) ?? draft;
    final resolvedPayments = _resolvePayments(cart.payments, cart.totalPayable);

    await _localDataSource.saveSale(
      businessId: businessId,
      dto: finalizedDto,
      items: cart.items,
      lineDtos: finalizedDto.lines,
      payments: resolvedPayments,
    );

    return _mapToPosSale(
      finalizedDto: finalizedDto,
      cart: cart,
      payments: resolvedPayments,
      partyId: partyId,
      customerName: customerName,
      notes: notes,
    );
  }

  List<PaymentEntry> _resolvePayments(
    List<PaymentEntry> payments,
    double totalPayable,
  ) {
    if (payments.isNotEmpty) {
      return payments;
    }
    return [PaymentEntry(mode: PaymentMode.cash, amount: totalPayable)];
  }

  PosSale _mapToPosSale({
    required SalesDocumentDto finalizedDto,
    required PosCartState cart,
    required List<PaymentEntry> payments,
    String? partyId,
    String? customerName,
    String? notes,
  }) {
    final totalAmount =
        cart.subtotal - cart.totalDiscount - cart.billDiscountAmount;
    final taxAmount = cart.totalTax;
    final finalAmount = cart.totalPayable;
    final completedAt =
        DateTime.tryParse(finalizedDto.createdAt) ?? DateTime.now();

    final saleItems = <PosSaleLineItem>[];
    for (var i = 0; i < cart.items.length; i++) {
      final cartItem = cart.items[i];
      final lineDto = i < finalizedDto.lines.length
          ? finalizedDto.lines[i]
          : null;
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
      partyId: partyId ?? PosConstants.walkInPartyId,
      customerName: customerName,
      items: saleItems,
      payments: payments,
      paymentMethod: payments.map((p) => _paymentModeToApi(p.mode)).join(','),
      totalAmount: totalAmount,
      taxAmount: taxAmount,
      finalAmount: finalAmount,
      completedAt: completedAt,
      notes: notes,
      itemCount: cart.items.fold<int>(0, (sum, item) => sum + item.quantity),
    );
  }

  String _paymentModeToApi(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => 'cash',
    PaymentMode.upi => 'upi',
    PaymentMode.card => 'card',
    PaymentMode.bank => 'bank_transfer',
  };
}
