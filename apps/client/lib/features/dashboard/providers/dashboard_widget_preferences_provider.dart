import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_widget_preferences_provider.g.dart';

const _defaultWidgets = <DashboardSideWidget>[
  DashboardSideWidget.purchases,
  DashboardSideWidget.expenses,
  DashboardSideWidget.lowStock,
  DashboardSideWidget.bankBalance,
];

@Riverpod(keepAlive: true)
class DashboardWidgetPreferences extends _$DashboardWidgetPreferences {
  @override
  List<DashboardSideWidget> build() {
    ref.listen(currentBusinessProvider, (_, _) {
      ref.invalidateSelf();
    });
    _load();
    return List<DashboardSideWidget>.from(_defaultWidgets);
  }

  String? get _storageKey {
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null || businessId.isEmpty) return null;
    return '${StorageKeys.dashboardSideWidgets}_$businessId';
  }

  Future<void> _load() async {
    final key = _storageKey;
    if (key == null) return;

    final storage = await ref.read(storageServiceProvider.future);
    final raw = storage.read(key);
    if (raw == null || raw.isEmpty) return;

    final parsed = DashboardSideWidget.fromIdsOrdered(raw.split(','));
    if (parsed.isNotEmpty) {
      state = parsed;
    }
  }

  Future<void> _persist(List<DashboardSideWidget> widgets) async {
    final key = _storageKey;
    if (key == null) return;

    final storage = await ref.read(storageServiceProvider.future);
    final value = widgets.map((w) => w.id).join(',');
    await storage.write(key, value);
  }

  void toggle(DashboardSideWidget widget) {
    final next = List<DashboardSideWidget>.from(state);
    final index = next.indexOf(widget);
    if (index >= 0) {
      next.removeAt(index);
    } else {
      next.add(widget);
    }
    state = next;
    _persist(next);
  }

  bool isEnabled(DashboardSideWidget widget) => state.contains(widget);
}

@Riverpod(keepAlive: true)
class DashboardActiveTab extends _$DashboardActiveTab {
  @override
  DashboardHomeTab build() => DashboardHomeTab.dashboard;

  void select(DashboardHomeTab tab) => state = tab;
}
