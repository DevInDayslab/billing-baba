import 'package:billing_baba/features/export/application/export_output_service.dart';
import 'package:billing_baba/features/export/application/export_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_providers.g.dart';

@Riverpod(keepAlive: true)
ExportService exportService(Ref ref) {
  return ExportService();
}

@Riverpod(keepAlive: true)
ExportOutputService exportOutputService(Ref ref) {
  return ExportOutputService();
}
