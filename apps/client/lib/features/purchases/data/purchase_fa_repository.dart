import 'package:billing_baba/features/purchases/data/purchase_fa_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_fa_remote_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_fa_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_fa_requests.dart';

class PurchaseFaRepository {
  PurchaseFaRepository({
    required this._remote,
    this._local,
  });

  final PurchaseFaRemoteDataSource _remote;
  // ignore: unused_field
  final PurchaseFaLocalDataSource? _local;

  Future<PaginatedPurchaseFaBatchesDto> listBatches(
    PurchaseFaListQuery query,
  ) => _remote.listBatches(query);

  Future<PurchaseFaBatchDto> getBatch(String batchId) =>
      _remote.getBatch(batchId);

  Future<PurchaseFaBatchDto> createBatch(CreatePurchaseFaRequest request) =>
      _remote.createBatch(request);

  Future<PurchaseFaBatchDto> updateBatch(
    String batchId,
    UpdatePurchaseFaRequest request,
  ) => _remote.updateBatch(batchId, request);

  Future<void> deleteBatch(String batchId) => _remote.deleteBatch(batchId);
}
