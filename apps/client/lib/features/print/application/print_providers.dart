import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/generated_documents/application/generated_document_providers.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/print/application/print_data_service.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/application/print_service.dart';
import 'package:billing_baba/features/print/data/print_remote_data_source.dart';
import 'package:billing_baba/features/print/data/print_repository.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/templates/template_registry.dart';
import 'package:billing_baba/features/purchases/data/expense_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/expense_repository.dart';
import 'package:billing_baba/features/purchases/data/purchase_fa_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_fa_repository.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_repository.dart';
import 'package:billing_baba/features/sales/data/job_work_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/job_work_repository.dart';
import 'package:billing_baba/features/sales/data/sale_fa_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/sale_fa_repository.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/settings/application/print_settings_provider.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_providers.g.dart';

@Riverpod(keepAlive: true)
Future<PrintRepository> printRepository(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return PrintRepository(
    remote: PrintRemoteDataSource(api.dio),
  );
}

@Riverpod(keepAlive: true)
Future<PrintDataService> printDataService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final businessService = await ref.watch(businessServiceProvider.future);
  final printRepository = await ref.watch(printRepositoryProvider.future);
  final imageService = ref.watch(imageServiceProvider);

  return PrintDataService(
    salesRepository: SalesRepository(
      remote: SalesRemoteDataSource(api.dio),
      local: const SalesLocalDataSource(),
    ),
    purchaseRepository: PurchaseRepository(
      remote: PurchaseRemoteDataSource(api.dio),
      local: const PurchaseLocalDataSource(),
    ),
    inventoryRepository: InventoryRepository(
      remote: InventoryRemoteDataSource(api.dio),
    ),
    printRepository: printRepository,
    businessService: businessService,
    partyRepository: PartyRepository(api.dio),
    expenseRepository: ExpenseRepository(
      remote: ExpenseRemoteDataSource(api.dio),
    ),
    purchaseFaRepository: PurchaseFaRepository(
      remote: PurchaseFaRemoteDataSource(api.dio),
    ),
    saleFaRepository: SaleFaRepository(
      remote: SaleFaRemoteDataSource(api.dio),
    ),
    jobWorkRepository: JobWorkRepository(
      remote: JobWorkRemoteDataSource(api.dio),
    ),
    imageService: imageService,
  );
}

@Riverpod(keepAlive: true)
TemplateRegistry templateRegistry(Ref ref) {
  return TemplateRegistry();
}

@Riverpod(keepAlive: true)
PrintOutputService printOutputService(Ref ref) {
  return PrintOutputService();
}

@Riverpod(keepAlive: true)
Future<PrintService> printService(Ref ref) async {
  final dataService = await ref.watch(printDataServiceProvider.future);
  final printSettingsRepository =
      await ref.watch(printSettingsRepositoryProvider.future);
  final generatedDocumentService =
      await ref.watch(generatedDocumentServiceProvider.future);
  return PrintService(
    dataService: dataService,
    outputService: ref.watch(printOutputServiceProvider),
    templateRegistry: ref.watch(templateRegistryProvider),
    printSettingsRepository: printSettingsRepository,
    generatedDocumentService: generatedDocumentService,
  );
}

@riverpod
Future<PrintableDocument> printableDocument(Ref ref, PrintRequest request) {
  return ref
      .watch(printDataServiceProvider.future)
      .then(
        (service) => service.load(request),
      );
}
