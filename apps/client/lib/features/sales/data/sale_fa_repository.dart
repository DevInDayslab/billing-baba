import 'package:billing_baba/features/sales/data/sale_fa_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sale_fa_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/sale_fa_dto.dart';
import 'package:billing_baba/features/sales/models/requests/sale_fa_requests.dart';

class SaleFaRepository {
  SaleFaRepository({
    required this._remote,
    this._local,
  });

  final SaleFaRemoteDataSource _remote;
  // ignore: unused_field
  final SaleFaLocalDataSource? _local;

  Future<PaginatedSaleFaBatchesDto> listBatches(SaleFaListQuery query) =>
      _remote.listBatches(query);

  Future<SaleFaBatchDto> getBatch(String batchId) => _remote.getBatch(batchId);

  Future<SaleFaBatchDto> createBatch(CreateSaleFaRequest request) =>
      _remote.createBatch(request);

  Future<SaleFaBatchDto> updateBatch(
    String batchId,
    UpdateSaleFaRequest request,
  ) => _remote.updateBatch(batchId, request);

  Future<void> deleteBatch(String batchId) => _remote.deleteBatch(batchId);
}
