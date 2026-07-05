import 'package:billing_baba/features/print/data/print_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';

class PrintRepository {
  PrintRepository({required this._remote});

  final PrintRemoteDataSource _remote;

  Future<PaymentDto> getPayment(String id) => _remote.getPayment(id);
}
