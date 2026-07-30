import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalesRepository.getDocument', () {
    late AppDatabase db;
    late SalesLocalDataSource local;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      local = SalesLocalDataSource(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('returns local document without calling remote', () async {
      const docId = 'doc-local-1';
      await local.upsertDocument(
        id: docId,
        businessId: 'biz-1',
        documentType: 'tax_invoice',
        status: 'finalized',
        documentSeries: 'INV',
        documentNumber: 'INV-001',
        isGstFormal: true,
        subtotal: '100',
        discountTotal: '0',
        taxAmount: '18',
        totalAmount: '118',
        documentDate: '2026-07-28',
        syncVersion: 1,
        createdAt: DateTime.utc(2026, 7, 28),
        updatedAt: DateTime.utc(2026, 7, 28),
      );
      await local.replaceLines(
        businessId: 'biz-1',
        salesDocumentId: docId,
        lines: [],
      );

      final repo = SalesRepository(
        remote: _FailingRemote(),
        local: local,
      );

      final doc = await repo.getDocument(docId);
      expect(doc.id, docId);
      expect(doc.documentNumber, 'INV-001');
    });
  });
}

class _FailingRemote extends SalesRemoteDataSource {
  _FailingRemote() : super(Dio());

  @override
  Future<SalesDocumentDto> getDocument(String id) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/sales/$id'),
      type: DioExceptionType.connectionError,
    );
  }
}
