import 'package:billing_baba/features/inventory/models/dto/movement_dto.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';

class StockTransferReportBuildResult {
  const StockTransferReportBuildResult({
    required this.rows,
    required this.meta,
    required this.totalQtyTransferred,
    required this.totalValue,
  });

  final List<ReportStockTransferRow> rows;
  final ReportPaginationMeta meta;
  final double totalQtyTransferred;
  final double totalValue;
}

double _movementDelta(MovementDto movement) =>
    double.tryParse(movement.quantityDelta) ?? 0;

double _movementCost(MovementDto movement) =>
    double.tryParse(movement.costPerUnit ?? '') ?? 0;

StockTransferReportBuildResult buildStockTransferReportFromMovements({
  required List<MovementDto> movements,
  required ReportQuery query,
}) {
  final q = query.q?.trim().toLowerCase();
  final grouped = <String, List<MovementDto>>{};

  for (final movement in movements) {
    final key =
        movement.referenceId?.trim().isNotEmpty == true
            ? movement.referenceId!.trim()
            : movement.id;
    grouped.putIfAbsent(key, () => []).add(movement);
  }

  final rows = <ReportStockTransferRow>[];
  for (final entry in grouped.entries) {
    final refKey = entry.key;
    final group = entry.value;
    MovementDto? outMovement;
    MovementDto? inMovement;
    for (final movement in group) {
      final delta = _movementDelta(movement);
      if (delta < 0) outMovement = movement;
      if (delta > 0) inMovement = movement;
    }
    final primary = outMovement ?? inMovement ?? group.first;

    final itemName = primary.itemName;
    if (q != null && q.isNotEmpty && !itemName.toLowerCase().contains(q)) {
      continue;
    }

    final qty = _movementDelta(primary).abs();
    final value = qty * _movementCost(primary);
    final date = DateTime.tryParse(primary.createdAt) ?? DateTime.now();
    final refNo =
        primary.referenceNumber?.trim().isNotEmpty == true
            ? primary.referenceNumber!.trim()
            : refKey;

    rows.add(
      ReportStockTransferRow(
        date: date,
        refNo: refNo,
        fromGodown: outMovement?.godownName ?? '',
        toGodown: inMovement?.godownName ?? '',
        itemName: itemName,
        quantity: qty,
        value: value,
      ),
    );
  }

  rows.sort((a, b) => b.date.compareTo(a.date));

  var totalQty = 0.0;
  var totalValue = 0.0;
  for (final row in rows) {
    totalQty += row.quantity;
    totalValue += row.value;
  }

  final reportPage = query.page < 1 ? 1 : query.page;
  final reportLimit = query.limit < 1 ? 20 : query.limit;
  final start = (reportPage - 1) * reportLimit;
  final pageRows = start >= rows.length
      ? const <ReportStockTransferRow>[]
      : rows.skip(start).take(reportLimit).toList();
  final totalPages = rows.isEmpty ? 1 : (rows.length / reportLimit).ceil();

  return StockTransferReportBuildResult(
    rows: pageRows,
    totalQtyTransferred: totalQty,
    totalValue: totalValue,
    meta: ReportPaginationMeta(
      page: reportPage,
      limit: reportLimit,
      total: rows.length,
      totalPages: totalPages,
    ),
  );
}
